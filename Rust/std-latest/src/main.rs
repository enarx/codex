use std::io::{Read, Write};
use std::net::TcpStream;
#[cfg(unix)]
use std::os::unix::io::{FromRawFd, RawFd};
#[cfg(target_os = "wasi")]
use std::os::wasi::io::{FromRawFd, RawFd};
use std::str::FromStr;
use std::{env, io};

use anyhow::{bail, Context};
use httparse::Status;

fn main() -> anyhow::Result<()> {
    let fd_count = env::var("FD_COUNT").context("failed to lookup `FD_COUNT`")?;
    let fd_count = usize::from_str(&fd_count).context("failed to parse `FD_COUNT`")?;
    assert_eq!(
        fd_count,
        4, // STDIN, STDOUT, STDERR and the socket connected to the endpoint
        "unexpected amount of file descriptors received"
    );

    let stream_fd: RawFd = env::var("FD_NAMES")
        .context("failed to lookup `FD_NAMES`")?
        .splitn(fd_count, ':')
        .position(|name| name == "api.github.com")
        .context("`api.github.com` socket not found")?
        .try_into()
        .unwrap(); // the value is at most 3 and therefore always fits into RawFd
    let mut stream = unsafe { TcpStream::from_raw_fd(stream_fd) };

    let req = vec![
        "GET /repos/enarx/enarx/releases?per_page=1 HTTP/1.0",
        "Host: api.github.com",
        "Accept: */*",
        &format!(
            "User-Agent: {}:{}",
            env!("CARGO_PKG_NAME"),
            env!("CARGO_PKG_VERSION")
        ),
        "\r\n",
    ]
    .join("\r\n");
    assert_eq!(
        io::copy(&mut req.as_bytes(), &mut stream).context("failed to send request")?,
        req.len() as u64
    );
    stream.flush().context("failed to flush stream")?;

    let mut buf = Vec::new();
    stream
        .read_to_end(&mut buf)
        .context("failed to read response")?;

    let mut headers = [httparse::EMPTY_HEADER; 64];
    let mut res = httparse::Response::new(&mut headers);
    let n = match res.parse(&buf).context("failed to parse HTTP response")? {
        Status::Complete(n) => n,
        Status::Partial => bail!("partial response"),
    };
    match res.code {
        Some(200) => {}
        Some(c) => bail!("unexpected response code {c}"),
        None => bail!("unknown response code"),
    }

    match serde_json::from_slice(&buf[n..]).context("failed to decode JSON")? {
        serde_json::Value::Array(releases) => {
            match releases.first().context("no releases available")? {
                serde_json::Value::Object(release) => {
                    let name = release
                        .get("name")
                        .context("release name missing")?
                        .as_str()
                        .context("release name is not a string")?;
                    eprintln!("Latest https://github.com/enarx/enarx release is:");
                    println!("{name}");
                    Ok(())
                }
                _ => bail!("release is not a JSON object"),
            }
        }
        _ => bail!("response is not a JSON array"),
    }
}

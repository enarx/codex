//! A "tiny" example of HTTP request/response handling using transports.
//!
//! This example is intended for *learning purposes* to see how various pieces
//! hook up together and how HTTP can get up and running. Note that this example
//! is written with the restriction that it *can't* use any "big" library other
//! than Tokio, if you'd like a "real world" HTTP library you likely want a
//! crate like Hyper.
//!
//! Code here is based on the `tinyhttp` example of tokio.

#![warn(rust_2018_idioms)]

use ::http::{Request, Response, StatusCode};
use futures::SinkExt;
use http::header::{CACHE_CONTROL, CONTENT_TYPE, LAST_MODIFIED};
use protocol::Http;
use std::os::wasi::io::FromRawFd;
use std::{error::Error, io};
use tokio::net::{TcpListener, TcpStream};
use tokio_stream::StreamExt;
use tokio_util::codec::Framed;

mod date;
mod protocol;

fn enarx_logo() -> &'static [u8] {
    include_bytes!("enarx-white.svg")
}

fn fireworks_gif() -> &'static [u8] {
    include_bytes!("fireworks.gif")
}

fn index_page() -> &'static [u8] {
    include_bytes!("index.html")
}

const NOT_FOUND: &str = r#"
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
</body></html>
"#;

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn Error>> {
    // Parse the arguments, bind the TCP socket we'll be listening to, spin up
    // our worker threads, and start shipping sockets to those worker threads.
    /*    let addr = env::args()
            .nth(1)
            .unwrap_or_else(|| "127.0.0.1:8080".to_string());
        let server = TcpListener::bind(&addr).await?;
    */
    let listener = unsafe { std::net::TcpListener::from_raw_fd(3) };
    listener.set_nonblocking(true).unwrap();
    let server = TcpListener::from_std(listener).unwrap();

    loop {
        eprintln!("Accepting connections");
        let stream_res = server.accept().await;
        match stream_res {
            Err(e) => {
                eprintln!("failed to accept connection; error = {}", e);
            }
            Ok((stream, _)) => {
                tokio::spawn(async move {
                    if let Err(e) = process(stream).await {
                        eprintln!("failed to process connection; error = {}", e);
                    }
                });
            }
        }
    }
}

async fn process(stream: TcpStream) -> Result<(), Box<dyn Error>> {
    let mut transport = Framed::new(stream, Http);

    while let Some(request) = transport.next().await {
        match request {
            Ok(request) => {
                let response = respond(request).await?;
                transport.send(response).await?;
            }
            Err(e) => return Err(e.into()),
        }
    }

    Ok(())
}

async fn respond(req: Request<()>) -> Result<Response<Vec<u8>>, Box<dyn Error>> {
    let response = Response::builder();
    let now_str = date::now().to_string();
    let response = match req.uri().path() {
        "/enarx-logo.svg" => response
            .status(StatusCode::OK)
            .header(CONTENT_TYPE, "image/svg+xml")
            .header(LAST_MODIFIED, &now_str)
            .header(CACHE_CONTROL, "max-age=60, public")
            .body(enarx_logo().to_vec()),
        "/fireworks.gif" => response
            .status(StatusCode::OK)
            .header(CONTENT_TYPE, "image/gif")
            .header(LAST_MODIFIED, &now_str)
            .header(CACHE_CONTROL, "max-age=60, public")
            .body(fireworks_gif().to_vec()),
        "/" => response
            .status(StatusCode::OK)
            .header(CONTENT_TYPE, "text/html; charset=UTF-8")
            .header(LAST_MODIFIED, &now_str)
            .header(CACHE_CONTROL, "max-age=60, public")
            .body(index_page().to_vec()),
        _ => response
            .status(StatusCode::NOT_FOUND)
            .header(CONTENT_TYPE, "text/html; charset=UTF-8")
            .header(LAST_MODIFIED, &now_str)
            .header(CACHE_CONTROL, "no-store, must-revalidate")
            .body(NOT_FOUND.as_bytes().to_vec()),
    };

    let response = response.map_err(|err| io::Error::new(io::ErrorKind::Other, err))?;

    Ok(response)
}

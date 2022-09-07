use std::io::{BufReader, Read, Write};
use std::net::TcpStream;

// When build to wasi
#[cfg(target_os = "wasi")]
fn get_tcpstream() -> std::result::Result<TcpStream, Box<dyn std::error::Error>> {
    use std::os::wasi::io::FromRawFd;
    let stdstream = unsafe { std::net::TcpStream::from_raw_fd(3) };
    Ok(stdstream)
}

// When the target of the build is not wasi
#[cfg(not(target_os = "wasi"))]
fn get_tcpstream() -> std::result::Result<TcpStream, std::io::Error> {
    std::net::TcpStream::connect("127.0.0.1:10010")
}

fn main() {
    // Use the TCP connection
    match get_tcpstream() {
        Ok(mut _stream) => {
            println!("Successfully connected to server.");

            // Send data over TCP
            let mut request_data = String::new();
            request_data.push_str("GET / HTTP/1.0\r\n\r\n");
            println!("request_data = {:?}", request_data);
            let _result = _stream.write_all(request_data.as_bytes());
            
            // Receive data from TCP
            let mut reader = BufReader::new(_stream);
            // Echo TCP server returns our request
            // We read the same amount of bytes
            let byte_count = request_data.len();
            let mut data = vec![0; byte_count];
            reader.read(&mut data).unwrap(); // Read from TCP
            let data_str = std::str::from_utf8(&data).unwrap();
            println!("{:?}", data_str);
        },
	Err(e) => {
            println!("Failed to connect: {}", e);
        }
    }
    println!("Finished.");
}

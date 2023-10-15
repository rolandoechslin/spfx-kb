# Browser URL

All images and links are coming from: https://blog.bytebytego.com/archive

## What happens when you type a URL into a browser

![What happens when you type a URL into a browser](https://substackcdn.com/image/fetch/w_1456,c_limit,f_webp,q_auto:good,fl_lossy/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fd10513d0-7467-4fc8-91f5-9ae5ff7ef342_1280x1664.gif)

--- 

Step 1: The user enters a URL (www. bytebytego. com) into the browser and hits Enter. The first thing we need to do is to translate the URL to an IP address. The mapping is usually stored in a cache, so the browser looks for the IP address in multiple layers of cache: the browser cache, OS cache, local cache, and ISP cache. If the browser couldn’t find the mapping in the cache, it will ask the DNS (Domain Name System) resolver to resolve it.

Step 2: If the IP address cannot be found at any of the caches, the browser goes to DNS servers to do a recursive DNS lookup until the IP address is found.

Step 3: Now that we have the IP address of the server, the browser sends an HTTP request to the server. For secure access of server resources, we should always use HTTPS. It first establishes a TCP connection with the server via TCP 3-way handshake. Then it sends the public key to the client. The client uses the public key to encrypt the session key and sends to the server. The server uses the private key to decrypt the session key. The client and server can now exchange encrypted data using the session key.

Step 4: The server processes the request and sends back the response. For a successful response, the status code is 200. There are 3 parts in the response: HTML, CSS and Javascript. The browser parses HTML and generates DOM tree. It also parses CSS and generates CSSOM tree. It then combines DOM tree and CSSOM tree to render tree. The browser renders the content and display to the user.

--- 

[HTTP Status Codes Explained In 5 Minutes](https://www.youtube.com/watch?v=qmpUfWN7hh4)

[A Crash Course in DNS (Domain Name System)](https://blog.bytebytego.com/p/a-crash-course-in-dns-domain-name)

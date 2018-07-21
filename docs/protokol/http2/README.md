# HTTP/2



**This is a listing of tools for analysing, debugging and visualising HTTP/2. See also the [Implementations listing](Implementations).**

* [Curl](http://curl.haxx.se) supports HTTP/2<sup>1</sup> as of 7.43.0. See its [documentation](http://curl.haxx.se/docs/http2.html) for details (including prerequisites).
* [h2i](https://github.com/golang/net/tree/master/http2/h2i) is a command-line interactive client that lets you send H2 frames, translate H1 to H2, and generally figure out how the protocol works.
* [h2load](https://nghttp2.org/documentation/h2load-howto.html) is a benchmarking / load generation tool for HTTP/2 and SPDY.
* [nghttp](https://nghttp2.org/documentation/nghttp.1.html) is a non-interactive command line HTTP/2 client that has plenty of debugging options, such as changing flow control window, dumping frames, HTTP Upgrade etc.
* [nghttpd](https://nghttp2.org/documentation/nghttpd.1.html) is a simple static file HTTP/2 server that is very handy to debug client side implementations.
* [mitmproxy](https://mitmproxy.org/) is an interactive console program that allows traffic flows to be intercepted, inspected, modified and replayed. Can be used programmatically (Python).
* [is-http2](https://github.com/stefanjudis/is-http2-cli) lets you quickly find out if a host supports H2 from the command line.
* [jmeter](https://github.com/syucream/jmeter-http2-plugin) Jmeter HTTP/2 sampler via - Netty 5 and netty-tcnative &  hpack
* [jmeter](https://www.blazemeter.com/blog/the-new-http2-plugin-for-jmeter-the-complete-guide) JMeter HTTP/2 Request sampler and View Result Tree Http2 listener plugin installable with [JMeter Plugins Manager](https://jmeter-plugins.org/wiki/PluginsManager/)
* [HTTP/2 Test](https://tools.keycdn.com/http2-test) is an online tool to check if a website supports HTTP/2.
* [HTTP2.Pro](https://http2.pro) is an online tool to check HTTP/2, ALPN, and Push support of web sites.
* [Wireshark](https://wireshark.org/) has a [HTTP/2 decoder](https://wiki.wireshark.org/HTTP2)<sup>2</sup>.
* [h2c](https://github.com/fstab/h2c) - A Simple HTTP/2 Command-Line Client
* [h2spec](https://github.com/summerwind/h2spec) - Conformance testing tool for HTTP/2 implementations
* [http2fuzz](https://github.com/c0nrad/http2fuzz) is a semi-intelligent fuzzer for HTTP/2.
* [WProf](http://wprof.cs.washington.edu/) extracts dependencies of activities during a page load, to identify bottlenecks. 
* [LoadRunner](http://community.hpe.com/t5/LoadRunner-and-Performance/How-to-gain-the-best-from-LoadRunner-s-support-of-HTTP-2/ba-p/6863547#.V1Yp7ZMrJZo) emulates HTTP/2 browsers (but not server push) to generate artificial load on servers as an enterprise-grade framework with GUI analytics.  
* [Vegeta](https://github.com/tsenart/vegeta) OS load tool that supports h2 through Go's (>= 1.6) net/http API  
* [HTTP/1 vs HTTP/2 speed test](https://www.dareboost.com/en/website-speed-test-http2-vs-http1) an online tool to test and compare speed of HTTP/2-ready websites, via HTTP/2 versus via HTTP/1 (disabling h2 support in Chrome) 

---

<sup>1</sup> Curl is strictly an [implementation](Implementations), but it's listed here because many people use it as a tool.

<sup>2</sup> Note that to use it on TLS-protected connections, you'll need to do [NSS Keylogging](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS/Key_Log_Format). See also the [Wireshark SSL/TLS docs](https://wiki.wireshark.org/SSL).



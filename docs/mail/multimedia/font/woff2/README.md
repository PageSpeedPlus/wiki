### Prolog

Google Chrome Developers [says](http://blog.chromium.org/2014/05/chrome-36-beta-elementanimate-html.html):
> The new WOFF 2.0 Web Font compression format offers a 30% average gain over WOFF 1.0 (up to 50%+ in some cases). WOFF 2.0 is available since Chrome 36 and Opera 23.

Some examples of file size differences: [WOFF vs. WOFF2](https://twitter.com/wpseo/status/482516050303807490)

### TTF to WOFF2 converting

* http://www.fontsquirrel.com/tools/webfont-generator
* http://everythingfonts.com/ttf-to-woff2


### Embed WOFF2 in CSS (with WOFF fallback)

```css
@font-face {
	font-family: MyFont;
	src:
		url('myfont.woff2') format('woff2'),
		url('myfont.woff') format('woff');
}
```

### Base64 Data-URI
Of course you can use WOFF2 as a Base64 encoded string:

```css
@font-face {
	font-family: MyFont;
	src:
		url('data:font/woff2;base64,...') format('woff2'),
		url('data:font/woff;base64,...') format('woff');
}
```

### Good to know

* Please no serverside GZIP compression for WOFF files, because WOFF already contains compressed data.
* Think about the correct mime type for WOFF 2.0 files (Google uses _font/woff2_. W3C [recommends](http://dev.w3.org/webfonts/WOFF2/spec/#IMT) _application/font-woff2_):

## NGINX: WOFF2 mime type

```nginx
types {
    application/font-woff2  woff2;
}
```

### Browser Support

* Google Chrome 36
* Opera 23
* Firefox 35 (disabled by default)

### WOFF2 - Helpful links

* [Can I use WOFF2](http://caniuse.com/#feat=woff2)
* [W3C: WOFF File Format 2.0](http://dev.w3.org/webfonts/WOFF2/spec/)
* [A better web font compression format: WOFF 2.0](https://groups.google.com/a/chromium.org/forum/#!topic/chromium-dev/j27Ou4RtvQI/discussion)
* [Progress on smaller and more colorful fonts](http://lwn.net/Articles/573348/)
* [How to test WOFF 2.0](https://code.google.com/p/font-compression-reference/wiki/testing_woff2)
* [WOFF 2.0 Compression on Google Fonts](https://docs.google.com/spreadsheet/ccc?key=0AvcH1ZzSrGMGdGl6MGRhdVRzYjN3T1NZSTBLM0ZUMnc#gid=0)
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5NTczNDEwMTBdfQ==
-->
Mathemagical
============

## Usage and such

Things will go here.  Oh, yes.  They will.

## Origins

The `math_ml` gem is a perfectly fine MathML parser, but for my needs, it had a few issues:

* It requires `eim_xml`.  I'd prefer not to introduce an XML generation library into production if I don't have to.  This library uses a simple homegrown XML generation system that covers all our needs without an extra, unverified gem floating about.
* It lacks a binscript.  Not a huge deal, but I'd have to write one anyhow since it's GPL2.
* It's crufty and had a few bugs.  I'll continually be improving the quality of the code as I work on this.
* There was no place to contribute to the code that I could find.

So I decided to fork it.  Since most interpretations of the GPL say that if you fork, you must rename, I decided to rename my fork to Mathemagical.

## License

The original `math_ml` gem is license under the GPL Version 2.  My modifications are licensed under the BSD License or whatever is most liberal, but since the original code is all GPL2, it doesn't really matter much.
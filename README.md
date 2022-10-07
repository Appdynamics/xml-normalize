# xml-normalize
a simple tool to normalize xml files to allow textual comparison

it canonicalizes the xml file by recursively sorting elements.
the attributes of elements are also sorted.

a very common use case is to normalize glassfish domain.xml files
from disparate versions to see the substantive changes.

these can then be put under some source code discipline.  the standard
java xml writer does not output the domain.xml in any kind of canonical
form.

the program has a trivial usage:

xml-normal.sh infile outfile

so

xml-normal.sh domain.xml domain-normal.xml

diff domain-prev.normal.xml domain-normal.xml will give a usable diff

I've swizzled together a simple modification that runs diff over two xml files
that have been chewed on; this is found in xmldiff.sh

issues:
this thing does not handle comments well.  they are sorted together
within the upper level element.  ideally, we don't move comments or somehow bind them to the succeeding tag.

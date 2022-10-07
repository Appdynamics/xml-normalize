#!/bin/bash
# diff xml files that need normalizing
# author: curt mayer
# this needs to have a moderately recent xsltproc installed to work
#
attr=/tmp/transform-attr.xml
sort=/tmp/transform-sort.xml
left1=/tmp/left1.xml
right1=/tmp/right1.xml

XSLT=xsltproc

if [ "$#" -ne 2 ]; then
	echo "usage: $0 <xml file 1> <xml file 2>"
    exit -1
fi

left=$1
right=$2

rm -f $attr $sort $tfile1 $tfile2

# this is the first pass
# used to normalize attributes
cat > $attr <<- ATTR
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                >
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>

    <xsl:template match="node()">
        <xsl:copy>

		<!-- iterate over attributes in order and put them on the node -->
		<xsl:for-each select="@*">
			<xsl:sort select="name()"/>
			<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:for-each>

		<!-- iterate over children and output them -->
		<xsl:for-each select="node()">
			<xsl:apply-templates select="."/>
		</xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
ATTR

# this is the second pass
# used to normalize elements
cat > $sort <<- SORT
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                >
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>

    <xsl:template match="node()">
        <xsl:copy>

		<!-- iterate over attributes in order and put them on the node -->
		<xsl:for-each select="@*">
			<xsl:sort select="name()"/>
			<xsl:attribute name="{name()}">
			<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:for-each>

		<xsl:for-each select="node()">
			<xsl:sort select="concat(name(.),string(@*))"/>
			<xsl:sort select="string(.)"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
SORT

$XSLT --output - $attr $left | $XSLT --output $left1 $sort -
$XSLT --output - $attr $right | $XSLT --output $right1 $sort -
diff -w $left1 $right1
exit 0

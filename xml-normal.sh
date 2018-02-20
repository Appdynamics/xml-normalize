#!/bin/bash
# Copyright 2018 AppDynamics, Inc
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

attr=/tmp/transform-attr.xml
sort=/tmp/transform-sort.xml
tfile=/tmp/attr.xml

XSLT=xsltproc

if [ "$#" -ne 2 ]; then
	echo "usage: $0 <input xml file> <output xml file>"
    exit -1
fi

infile=$1
outfile=$2

rm -f $attr $sort $tfile

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

$XSLT --output - $attr $infile | $XSLT --output $outfile $sort -
exit 0

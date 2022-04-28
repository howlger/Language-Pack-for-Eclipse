<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl">
    <xsl:output method="html" omit-xml-declaration="yes" indent="yes"/>

    <!-- parameters -->
    <xsl:param name="extension"/>
    <xsl:param name="info-file"/>
    <xsl:param name="temp-dir"/>

    <!-- process specified extension -->
    <xsl:template match="/">

        <!-- languages -->
        <xsl:variable name="languages">
            <xsl:for-each select="o/o[@name='contributes']/a[@name='languages']/o">
                <xsl:variable name="language-id" select="e[@name='id']/@string"/>
                <xsl:variable name="grammars-count"
                    select="count(/o/o[@name='contributes']/a[@name='grammars']
                                      /o/e[@name='language'][@string=$language-id])"/>
                <xsl:if test="    not(document($info-file)/info/extension[@id=$extension]/language[@issues or @ignore])
                              and $grammars-count > 0
                              and a[@name='extensions' or @name='filenames' or @name='filenamePatterns']">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exsl:node-set($languages)/o">
            <table>
                <xsl:for-each select="exsl:node-set($languages)/o">
                    <tr>

                        <!-- language -->
                        <xsl:variable name="original-name" select="a[@name='aliases']/v[1]/@string"/>
                        <xsl:variable name="name">
                            <xsl:choose>
                                <xsl:when test="document($info-file)/info/extension[@id = $extension]
                                                   /language[@name = $original-name][@better-name]">
                                    <xsl:value-of select="document($info-file)/info/extension[@id = $extension]
                                                              /language[@name = $original-name]/@better-name"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$original-name"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <td>
                            <xsl:choose>
                                <xsl:when test="not(document(concat($temp-dir, e[@name='id']/@string, '_href.xml'))
                                                        /href/@text = '')">
                                    <a href="{document(concat($temp-dir, e[@name='id']/@string, '_href.xml'))/href/text()}">
                                        <xsl:value-of select="$name"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$name"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>

                        <!-- file associations -->
                        <xsl:variable name="file-names">
                            <xsl:for-each select="a[@name='extensions']/v">
                                <xsl:value-of select="concat(', *', @string)"/>
                            </xsl:for-each>
                            <xsl:for-each select="a[@name='filenames' or @name='filenamePatterns']/v">
                                <xsl:value-of select="concat(', ', @string)"/>
                            </xsl:for-each>
                        </xsl:variable>
                        <td><xsl:value-of select="substring($file-names, 3)"/></td>

                    </tr>
                </xsl:for-each>
            </table>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
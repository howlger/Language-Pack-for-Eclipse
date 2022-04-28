<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl">

    <!-- basename -->
    <xsl:template name="basename">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="translate($path, '/', '') = $path">
                <xsl:value-of select="$path"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="basename">
                     <xsl:with-param name="path" select="substring-after($path, '/')"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- encode -->
    <xsl:template name="encode">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="string-length($path) = 0">
                <xsl:value-of select="$path"/>
            </xsl:when>
            <xsl:when test="substring($path, 1, 1) = ' '">
                <xsl:text>%20</xsl:text>
                <xsl:call-template name="encode">
                     <xsl:with-param name="path" select="substring($path, 2)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="substring($path, 1, 1) = '('">
                <xsl:text>%28</xsl:text>
                <xsl:call-template name="encode">
                     <xsl:with-param name="path" select="substring($path, 2)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="substring($path, 1, 1) = ')'">
                <xsl:text>%29</xsl:text>
                <xsl:call-template name="encode">
                     <xsl:with-param name="path" select="substring($path, 2)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($path, 1, 1)"/>
                <xsl:call-template name="encode">
                     <xsl:with-param name="path" select="substring($path, 2)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- decode -->
    <xsl:template name="decode">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="string-length($path) = 0">
                <xsl:value-of select="$path"/>
            </xsl:when>
            <xsl:when test="substring($path, 1, 3) = '%20'">
                <xsl:text> </xsl:text>
                <xsl:call-template name="decode">
                     <xsl:with-param name="path" select="substring($path, 4)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($path, 1, 1)"/>
                <xsl:call-template name="decode">
                     <xsl:with-param name="path" select="substring($path, 2)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- info -->
    <xsl:template name="info">
        <xsl:param name="extension"/>
        <xsl:param name="info-file"/>
        <xsl:param name="temp-dir"/>
        <xsl:variable name="languages">
            <xsl:for-each select="o/o[@name='contributes']/a[@name='languages']/o">
                <xsl:variable name="language-id" select="e[@name='id']/@string"/>
                <xsl:variable name="grammars-count"
                    select="count(/o/o[@name='contributes']/a[@name='grammars']
                                      /o/e[@name='language'][@string=$language-id])"/>
                <xsl:if test="    not(document($info-file)/info/extension[@id=$extension]/language[@issues or @ignore])
                              and $grammars-count > 0
                              and a[@name='extensions' or @name='filenames' or @name='filenamePatterns']">
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
                    <xsl:variable name="file-associations">
                        <xsl:for-each select="a[@name='extensions']/v">
                            <xsl:value-of select="concat(', *', @string)"/>
                        </xsl:for-each>
                        <xsl:for-each select="a[@name='filenames' or @name='filenamePatterns']/v">
                            <xsl:value-of select="concat(', ', @string)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <language name="{$name}" file-associations="{substring($file-associations, 3)}">
                        <xsl:if test="not(document(concat($temp-dir, e[@name='id']/@string, '_href.xml'))/href/@text = '')">
                            <xsl:attribute name="href">
                                <xsl:call-template name="encode">
                                    <xsl:with-param name="path"
                                        select="document(concat($temp-dir, e[@name='id']/@string, '_href.xml'))/href/text()"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </xsl:if>
                    </language>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:apply-templates select="exsl:node-set($languages)/language" mode="info-language"/>
    </xsl:template>

</xsl:stylesheet>
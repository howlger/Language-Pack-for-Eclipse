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

</xsl:stylesheet>
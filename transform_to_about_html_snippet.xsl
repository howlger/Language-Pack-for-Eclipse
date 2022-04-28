<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl">
    <xsl:import href="transform_commons.xsl"/>
    <xsl:output method="html" omit-xml-declaration="yes" indent="yes"/>

    <!-- parameters -->
    <xsl:param name="extension"/>
    <xsl:param name="extension-href"/>
    <xsl:param name="temp-dir"/>

    <!-- process specified extension -->
    <xsl:template match="/">

        <!-- compute files -->
        <xsl:variable name="files">
            <xsl:for-each select="o/o[@name='contributes']/a[@name='languages']/o[e/@name='configuration']">
                <xsl:variable name="language-id" select="e[@name='id']/@string"/>
                <xsl:variable name="grammars-count"
                    select="count(/o/o[@name='contributes']/a[@name='grammars']
                                      /o/e[@name='language'][@string=$language-id])"/>
                <xsl:variable name="path" select="e[@name='configuration']/@string"/>
                <xsl:if test="    $grammars-count > 0
                              and a[@name='extensions' or @name='filenames' or @name='filenamePatterns']
                              and not(preceding-sibling::o/e[@name='configuration'][@string = $path])">
                    <file type="config">
                        <xsl:attribute name="basename">
                            <xsl:call-template name="basename">
                                 <xsl:with-param name="path" select="$path"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($extension-href, '/')"/>
                            <xsl:call-template name="encode">
                                <xsl:with-param name="path" select="e[@name='configuration']/@string"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </file>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="o/o[@name='contributes']/a[@name='grammars']/o[e/@name='scopeName'][e/@name='path']">
                <xsl:variable name="path" select="e[@name='path']/@string"/>
                <xsl:if test="not(preceding-sibling::o/e[@name='path'][@string = $path])">
                    <file type="grammar">
                        <xsl:attribute name="basename">
                            <xsl:call-template name="basename">
                                 <xsl:with-param name="path" select="$path"/>
                            </xsl:call-template>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat($extension-href, '/')"/>
                            <xsl:call-template name="encode">
                                <xsl:with-param name="path" select="e[@name='path']/@string"/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </file>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <!-- output files -->
        <xsl:if test="exsl:node-set($files)">
            <table>
                <xsl:for-each select="exsl:node-set($files)/file">
                    <tr>
                        <td><xsl:value-of select="concat($extension, '/', @basename)"/></td>
                        <xsl:if test="position() = 1">
                            <td>
                                <xsl:if test="count(exsl:node-set($files)/file) > 1">
                                    <xsl:attribute name="rowspan">
                                        <xsl:value-of select="count(exsl:node-set($files)/file)"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <a href="{$extension-href}" target="_blank"><xsl:value-of select="$extension"/></a>
                            </td>
                        </xsl:if>
                        <td><a href="{@href}" target="_blank"><xsl:value-of select="@basename"/></a></td>
                        <td>
                            <xsl:if test="@type = 'config'">
                                <xsl:text>-</xsl:text>
                            </xsl:if>
                            <xsl:if test="@type = 'grammar'">
                                <xsl:variable name="original-href"
                                    select="document(concat($temp-dir, @basename, '_original.xml'))
                                                /original/text()"/>
                                <xsl:choose>
                                    <xsl:when test="$original-href = ''">
                                        <xsl:text>???</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="basename">
                                            <xsl:call-template name="basename">
                                                 <xsl:with-param name="path" select="$original-href"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <a href="{$original-href}">
                                            <xsl:call-template name="decode">
                                                 <xsl:with-param name="path" select="$basename"/>
                                            </xsl:call-template>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
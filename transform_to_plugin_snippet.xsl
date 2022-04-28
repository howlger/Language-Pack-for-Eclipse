<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl">
    <xsl:import href="transform_commons.xsl"/>
    <xsl:output method="xml" indent="yes"/>

    <!-- parameters -->
    <xsl:param name="extension"/>
    <xsl:param name="info-file"/>

    <!-- process specified extension -->
    <xsl:template match="/">
        <lngpck-snippet>
            <xsl:comment><xsl:value-of select="concat(' ', $extension, ' ')"/></xsl:comment>

            <!-- issues? -->
            <xsl:if test="document($info-file)/info/extension[@id=$extension]/language/@issues">
                <xsl:comment>
                    <xsl:text> issues: </xsl:text>
                    <xsl:for-each select="document($info-file)/info/extension[@id=$extension]/language[@issues]">
                        <xsl:if test="position() > 1"><xsl:text>; </xsl:text></xsl:if>
                        <xsl:value-of select="@issues"/>
                    </xsl:for-each>
                    <xsl:text>>>></xsl:text>
                </xsl:comment>
            </xsl:if>

            <!-- languages -->
            <xsl:variable name="languages">
                <xsl:for-each select="o/o[@name='contributes']/a[@name='languages']/o">
                    <xsl:variable name="language-id" select="e[@name='id']/@string"/>
                    <xsl:variable name="grammars-count"
                        select="count(/o/o[@name='contributes']/a[@name='grammars']
                                          /o/e[@name='language'][@string=$language-id])"/>
                    <xsl:if test="    $grammars-count > 0
                                  and a[@name='extensions' or @name='filenames' or @name='filenamePatterns']">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="exsl:node-set($languages)/o">

                <!-- content types -->
                <extension point="org.eclipse.core.contenttype.contentTypes">
                    <xsl:for-each select="exsl:node-set($languages)/o">
                        <content-type id="lng.{e[@name='id']/@string}"
                            base-type="de.agilantis.language_pack.basetype"
                            name="{a[@name='aliases']/v[1]/@string} (Syntax Highlighting)"
                            priority="low">

                            <!-- file-extensions="..." -->
                            <xsl:variable name="file-extensions">
                                <xsl:for-each select="a[@name='extensions']/v">
                                    <xsl:if test="    substring(@string, 1, 1) = '.'
                                                  and translate(@string, '.', '') = substring(@string, 2)">
                                        <xsl:value-of select="concat(',', substring(@string, 2))"/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:if test="string-length($file-extensions) > 0">
                                <xsl:attribute name="file-extensions">
                                    <xsl:value-of select="substring($file-extensions, 2)"/>
                                </xsl:attribute>
                            </xsl:if>

                            <!-- file-names="..." -->
                            <xsl:variable name="file-names">
                                <xsl:for-each select="a[@name='filenames']/v">
                                    <xsl:value-of select="concat(',', @string)"/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:if test="string-length($file-names) > 0">
                                <xsl:attribute name="file-names">
                                    <xsl:value-of select="substring($file-names, 2)"/>
                                </xsl:attribute>
                            </xsl:if>

                            <!-- file-patterns="..." -->
                            <xsl:variable name="file-patterns">
                                <xsl:for-each select="a[@name='extensions']/v">
                                    <xsl:if test="   not(substring(@string, 1, 1) = '.')
                                                  or not(translate(@string, '.', '') = substring(@string, 2))">
                                        <xsl:value-of select="concat(',*', @string, 2)"/>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:for-each select="a[@name='filenamePatterns']/v">
                                    <xsl:value-of select="concat(',', @string)"/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:if test="string-length($file-patterns) > 0">
                                <xsl:attribute name="file-patterns">
                                    <xsl:value-of select="substring($file-patterns, 2)"/>
                                </xsl:attribute>
                            </xsl:if>

                        </content-type>
                    </xsl:for-each>
                </extension>

                <!-- language configurations -->
                <xsl:if test="exsl:node-set($languages)/o/e[@name='configuration']">
                    <extension point="org.eclipse.tm4e.languageconfiguration.languageConfigurations">
                        <xsl:for-each select="exsl:node-set($languages)/o[e/@name='configuration']">
                            <xsl:variable name="basename">
                                <xsl:call-template name="basename">
                                     <xsl:with-param name="path" select="e[@name='configuration']/@string"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <languageConfiguration contentTypeId="lng.{e[@name='id']/@string}"
                                path="{$extension}/{$basename}"/>
                        </xsl:for-each>
                    </extension>
                </xsl:if>

                <!-- editor icons -->
                <extension point="org.eclipse.ui.genericeditor.icons">
                    <xsl:for-each select="exsl:node-set($languages)/o">
                        <icon contentType="lng.{e[@name='id']/@string}" icon="lngeditor.png"/>
                    </xsl:for-each>
                </extension>

            </xsl:if>

            <!-- grammars -->
            <xsl:if test="o/o[@name='contributes']/a[@name='grammars']/o[e/@name='scopeName'][e/@name='path']">
                <extension point="org.eclipse.tm4e.registry.grammars">
                    <xsl:for-each select="o/o[@name='contributes']/a[@name='grammars']
                                              /o[e/@name='scopeName'][e/@name='path']">
                        <xsl:variable name="basename">
                            <xsl:call-template name="basename">
                                 <xsl:with-param name="path" select="e[@name='path']/@string"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <grammar scopeName="lngpck.{e[@name='scopeName']/@string}" path="{$extension}/{$basename}"/>
                        <xsl:if test="e[@name='language']">
                            <scopeNameContentTypeBinding scopeName="lngpck.{e[@name='scopeName']/@string}"
                                contentTypeId="lng.{e[@name='language']/@string}"/>
                        </xsl:if>
                    </xsl:for-each>
                </extension>
            </xsl:if>

            <xsl:if test="document($info-file)/info/extension[@id=$extension]/language/@issues">
                <xsl:comment><xsl:text>///</xsl:text></xsl:comment>
            </xsl:if>


        </lngpck-snippet>
    </xsl:template>

</xsl:stylesheet>
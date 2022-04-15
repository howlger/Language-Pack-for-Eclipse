<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common" exclude-result-prefixes="exsl">
    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="extension"/>

    <!-- process specified extension -->
    <xsl:template match="/">
        <lngpck-snippet>
            <xsl:text>&#xa;</xsl:text>
            <xsl:comment><xsl:value-of select="concat(' ', $extension, ' ')"/></xsl:comment>

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

                <!-- editors -->
                <extension point="org.eclipse.ui.genericeditor.presentationReconcilers">
                    <xsl:for-each select="exsl:node-set($languages)/o">
                        <presentationReconciler class="org.eclipse.tm4e.ui.text.TMPresentationReconciler"
                            contentType="lng.{e[@name='id']/@string}"/>
                    </xsl:for-each>
                </extension>
                <extension point="org.eclipse.ui.editors">
                    <xsl:for-each select="exsl:node-set($languages)/o">
                        <editor id="lngeditor.{e[@name='id']/@string}"
                            name="{a[@name='aliases']/v[1]/@string} Editor (Syntax Highlighting)"
                            icon="lngeditor.png"
                            class="org.eclipse.ui.internal.genericeditor.ExtensionBasedTextEditor"
                            contributorClass="org.eclipse.ui.editors.text.TextEditorActionContributor">
                            <contentTypeBinding contentTypeId="lng.{e[@name='id']/@string}"/>
                        </editor>
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

        </lngpck-snippet>
    </xsl:template>

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

</xsl:stylesheet>
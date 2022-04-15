<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>

    <!-- unique ID and URL of the extension -->
    <xsl:param name="base-url"/>

    <!-- process specified extension -->
    <xsl:template match="/">
        <project default="process-extension">
            <target name="process-extension">

                <!-- language configurations -->
                <xsl:for-each select="o/o[@name='contributes']/a[@name='languages']/o[e/@name='configuration']">
                    <xsl:variable name="language-id" select="e[@name='id']/@string"/>
                    <xsl:variable name="language-grammars-count"
                        select="count(/o/o[@name='contributes']/a[@name='grammars']/o/e[@name='language'][@string=$language-id])"/>
                    <xsl:if test="$language-grammars-count = 1">
                        <xsl:variable name="basename">
                            <xsl:call-template name="basename">
                                 <xsl:with-param name="path" select="e[@name='configuration']/@string"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <mkdir dir="${{project.build.directory}}/generated/${{extension}}"/>
                        <xsl:variable name="encoded-path">
                            <xsl:call-template name="encode">
                                 <xsl:with-param name="path" select="e[@name='configuration']/@string"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <get src="{$base-url}/{$encoded-path}"
                            dest="${{project.build.directory}}/generated_temp/${{extension}}/{$basename}"/>
                        <copy file="${{project.build.directory}}/generated_temp/${{extension}}/{$basename}"
                            todir="${{project.build.directory}}/generated/${{extension}}" encoding="UTF-8">
                            <filterchain>
                                <replaceregex flags="g" pattern="//[^&quot;\r\n]*+(?=$$|[\r\n])" replace=""/>
                                <replaceregex byline="no" flags="g"
                                    pattern="([&quot;\}}\]])\s*+,(?=\s*+[\}}\]]([\s\{{\}}\[\]:,]|&lt;[/]?[oaev](?:\s(?:name|string|number)=&quot;(?:[^&quot;\\]|\\.)*+&quot;)*+[/]?>|(&quot;([^&quot;\\]|\\.)*+&quot;)|([+-]?\d++(?:\.\d++)?(?:[eE][+-]?\d++)?))*+$$)"
                                    replace="\1"/>

                                <!-- not yet supported: { "pattern": "...", flags: "..." } -->
                                <replaceregex byline="no" flags="g"
                                    pattern="\{{\s*+&quot;pattern&quot;\s*+:\s*+(&quot;(?:[^&quot;\\]|\\.)*+&quot;)\s*+(?:,\s*+&quot;flags&quot;\s*+:\s*+&quot;[^&quot;]*+&quot;\s*+)?\}}"
                                    replace="\1"/>

                                <!-- not yet supported: "onEnterRules": [ ... ] -->
                                <replaceregex byline="no"
                                    pattern=",\s*+&quot;onEnterRules&quot;\s*+:\s*+\[([\s\{{\}}\[:,]|(&quot;([^&quot;\\]|\\.)*+&quot;)|([+-]?\d++(?:\.\d++)?(?:[eE][+-]?\d++)?))*+\s*+\]"
                                    replace=""/>

                            </filterchain>
                        </copy>
                    </xsl:if>
                </xsl:for-each>

                <!-- grammars  -->
                <xsl:for-each select="o/o[@name='contributes']/a[@name='grammars']/o[e/@name='scopeName'][e/@name='path']">
                    <mkdir dir="${{project.build.directory}}/generated/${{extension}}"/>
                    <xsl:variable name="basename">
                        <xsl:call-template name="basename">
                             <xsl:with-param name="path" select="e[@name='path']/@string"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="encoded-path">
                        <xsl:call-template name="encode">
                             <xsl:with-param name="path" select="e[@name='path']/@string"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <get src="{$base-url}/{$encoded-path}"
                        dest="${{project.build.directory}}/generated_temp/${{extension}}/{$basename}"/>
                    <copy file="${{project.build.directory}}/generated_temp/${{extension}}/{$basename}"
                        tofile="${{project.build.directory}}/generated_temp/${{extension}}/{$basename}.xml"
                        encoding="UTF-8">
                        <filterchain refid="json-to-xml"/>
                    </copy>
                    <copy file="${{project.build.directory}}/generated_temp/${{extension}}/{$basename}"
                        todir="${{project.build.directory}}/generated/${{extension}}" encoding="UTF-8">
                        <filterchain>
                            <replaceregex flags="g"
                                pattern="&quot;(?:scopeName|include)&quot;\s*+:\s*+&quot;(?![#\$])(?=[^&quot;]++&quot;)"
                                replace="\0lngpck."/>
                        </filterchain>
                    </copy>
                </xsl:for-each>

            </target>
        </project>
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

</xsl:stylesheet>
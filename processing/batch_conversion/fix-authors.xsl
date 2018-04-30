<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
        
    <xsl:variable name="newline" select="'&#10;'"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:value-of select="$newline"/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:author">
        <xsl:variable name="authortext" select="string-join(.//text(), '')"/>
        <xsl:variable name="authortextlen" select="string-length($authortext)"/>
        <xsl:choose>
            <xsl:when test="$authortextlen gt 0">
                <xsl:variable name="authors" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="substring($authortext, 1, ($authortextlen div 2)) eq substring($authortext, (($authortextlen div 2)+1))">
                            <!-- Sometimes the name is just repeated -->
                            <xsl:value-of select="substring($authortext, 1, ($authortextlen div 2))"/>
                        </xsl:when>
                        <xsl:when test="matches($authortext, '^\s*[^აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵჶჷჸ ]+\s*[აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵჶჷჸ ]+.*$')">
                            <!-- Sometimes two translations/transliterations of a name have been entered one after the other in the same field -->
                            <xsl:analyze-string select="$authortext" regex="[აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵჶჷჸ]+.*$">
                                <xsl:matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$authortext"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="$authors">
                        <persName>
                            <xsl:value-of select="."/>
                        </persName>
                    </xsl:for-each>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()"><xsl:copy/></xsl:template>
    
</xsl:stylesheet>
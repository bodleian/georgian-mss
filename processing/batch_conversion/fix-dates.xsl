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
    
    <xsl:template match="tei:origDate | tei:date[not(parent::tei:publicationStmt)]">
        <xsl:choose>
            <xsl:when test="text() = 'Gregorian' and not(@when)">
                <!-- Remove placeholders -->
                <!-- TODO: If reusing this script, insert the text "Undated" when this is an origDate and nothing else is in the parent origin -->
            </xsl:when>
            <xsl:when test="text() = 'Gregorian'">
                <!-- There are a couple of these in acquisition elements: display the year only -->
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="substring(@when, 1, 4)"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="@calendar = '#Gregorian'">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:if test="not(@when or @notBefore or @notAfter or @from or @to)">
                        <!-- Normalize -->
                        <xsl:choose>
                            <xsl:when test="matches(text(), '^\d\d\d\d?\??$')">
                                <!-- A year -->
                                <xsl:attribute name="when" select="tokenize(text(), '\?')[1]"/>
                            </xsl:when>
                            <xsl:when test="matches(text(), '^\d\d\d\d?\-\d\d\d\d?$')">
                                <!-- A year range -->
                                <xsl:attribute name="from" select="tokenize(text(), '\-')[1]"/>
                                <xsl:attribute name="to" select="tokenize(text(), '\-')[2]"/>
                            </xsl:when>
                            <xsl:when test="matches(text(), '^\d\d\d\d?\??\-$')">
                                <!-- An open-ended year range -->
                                <xsl:attribute name="notBefore" select="tokenize(text(), '\D')[1]"/>
                            </xsl:when>
                            <xsl:when test="matches(text(), '\d\d(st|nd|rd|th)', 'i') and not(matches(text(), '(early|late|half)', 'i'))">
                                <!-- Centuries: Doesn't work for BCE dates, but there aren't any of those in Gregorian -->
                                <xsl:variable name="centuries" as="xs:string*">
                                    <xsl:analyze-string select="text()" regex="([\d/]+)(st|nd|rd|th)" flags="i">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>
                                        </xsl:matching-substring>
                                    </xsl:analyze-string>
                                </xsl:variable>
                                <xsl:variable name="centuriesint" select="for $x in $centuries return for $y in tokenize($x, '/')[string-length(.) gt 0] return xs:integer($y)"/>
                                <xsl:variable name="earliestyear" select="(min($centuriesint) - 1) * 100"/>
                                <xsl:variable name="latestyear" select="max($centuriesint) * 100"/>
                                <xsl:attribute name="notBefore" select="string($earliestyear)"/>
                                <xsl:attribute name="notAfter" select="string($latestyear)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Multiple different date formats have been used, so for anything else just 
                                     create empty attributes to aid in manual fixing -->
                                <xsl:attribute name="when" select="''"/>
                                <xsl:attribute name="notBefore" select="''"/>
                                <xsl:attribute name="notAfter" select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- This shouldn't trigger in Gregorian as all dates are marked up as Gregorian -->
                <xsl:message>Non-Gregorian calendar date</xsl:message>
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
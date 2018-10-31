<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:variable name="newline" select="'&#10;'"/>
    
    <xsl:variable name="roottei" select="/tei:TEI"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:value-of select="$newline"/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>
    
    <xsl:template match="text()|comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*"><xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy></xsl:template>
    
    <xsl:template match="tei:item[@xml:id]">
        <xsl:copy>
            <xsl:attribute name="xml:id">
                <xsl:choose>
                    <xsl:when test="count(.//tei:ref/@target) eq 1">
                        <xsl:text>subject_</xsl:text>
                        <xsl:value-of select="tokenize((.//tei:ref)[1]/@target, '/')[last()]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>Cannot change xml:id</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:copy-of select="@*[not(name()='xml:id')]"/>
            <xsl:apply-templates/>            
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
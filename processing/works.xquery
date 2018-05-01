import module namespace bod = "http://www.bodleian.ox.ac.uk/bdlss" at "https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2solr.xquery";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare option saxon:output "indent=yes";

<add>
{
    let $doc := doc("../authority/works.xml")
    let $collection := collection("../collections?select=*.xml;recurse=yes")
    let $works := $doc//tei:listBibl/tei:bibl[@xml:id]
    let $copiesofworks := $doc//tei:listBibl/tei:bibl[@copyOf]
   
    for $work in $works
    
        let $id := $work/@xml:id/string()
        let $title := normalize-space($work/tei:title[@type="uniform"][1]/string())
        let $variants := $work//tei:title[@type="variant"]
        
        let $targetids := (for $i in ($work/tei:ref/@target/string(), $copiesofworks[@copyOf/string() = concat('#', $id)]/tei:ref/@target/string()) return substring-after($i, '#'))
        let $mss := $collection//tei:TEI[.//tei:msItem[@xml:id = $targetids]]
        
        return
        if (count($mss) > 0) then
        
            <doc>
                <field name="type">work</field>
                <field name="pk">{ $id }</field>
                <field name="id">{ $id }</field>
                <field name="title">{ $title }</field>
                <field name="wk_title_s">{ $title }</field>
                {
                for $variant in $variants
                    let $vname := normalize-space($variant/string())
                    order by $vname
                    return <field name="wk_variant_sm">{ $vname }</field>
                }
                <field name="alpha_title">{ 
                    if (contains($title, ':')) then
                        bod:alphabetize($title)
                    else
                        bod:alphabetizeTitle($title)
                }</field>
                {
                bod:languages($mss//tei:msItem[@xml:id = $targetids]//tei:textLang, 'lang_sm')
                }
                {
                for $ms in $mss
                    let $msid := $ms/@xml:id/string()
                    let $url := concat("/catalog/", $msid)
                    let $classmark := $ms//tei:msDesc/tei:msIdentifier/tei:idno[1]/text()
                    order by $classmark
                    return <field name="link_manuscripts_smni">{ concat($url, "|", $classmark) }</field>
                }
                {
                for $relatedid in distinct-values((tokenize(translate($work/@corresp, '#', ''), ' '), tokenize(translate($work/@sameAs, '#', ''), ' ')))
                    let $url := concat("/catalog/", $relatedid)
                    let $linktext := $doc//tei:listBibl/tei:bibl[@xml:id = $relatedid]/tei:title[@type="uniform"][1]/string()
                    return
                    <field name="link_related_smni">{ concat($url, "|", $linktext) }</field>
                }
            </doc>
        else
            (
            bod:logging('info', 'Skipping work in works.xml but not in any manuscript', ($id, $title))
            )
}
</add>

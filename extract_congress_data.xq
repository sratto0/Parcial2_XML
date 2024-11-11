declare namespace ns = "http://www.w3.org/2001/XMLSchema";

(: Extraer la información del <congress>, <sessions>, y <item> :)
let $congress := doc("congress_info.xml")/api-root/congress
let $members := doc("congress_members_info.xml")/api-root/members/member
let $sessions := $congress/sessions
let $items := $sessions/item

(: Filtrar miembros para cada cámara :)
let $houseMembers := 
  for $member in $members
  let $chambers := $member/terms/item/item/chamber
  where some $chamber in $chambers satisfies normalize-space($chamber) = "House of Representatives"
  return $member

let $senateMembers := 
  for $member in $members
  let $chambers := $member/terms/item/item/chamber
  where some $chamber in $chambers satisfies normalize-space($chamber) = "Senate"
  return $member

(: Generar la salida XML :)
return
  (
    <?xml-stylesheet type="text/xsl" href="generate_html.xsl"?>,

    <data>
      <congress>
        <name>{ $congress/name }</name>
        <period from="{ normalize-space($congress/startYear) }" to="{ normalize-space($congress/endYear) }" />
        
        <chambers>
          (: Tabla para House of Representatives :)
          <chamber>
            <name>House of Representatives</name>
            <members>
              {
                for $member in $houseMembers
                let $terms := $member/terms/item/item
                return
                  <member bioguideId="{ normalize-space($member/bioguideId) }">
                    <name>{ normalize-space($member/name) }</name>
                    <state>{ normalize-space($member/state) }</state>
                    <party>{ normalize-space($member/partyName) }</party>
                    <image_url>{ normalize-space($member/depiction/imageUrl) }</image_url>
                    {
                      for $term in $terms
                      let $houseTerm := normalize-space($term/startYear)
                      where normalize-space($term/chamber) = "House of Representatives"
                      return
                        <period from="{ $houseTerm }" to="{ normalize-space($term/endYear) }" />
                    }
                  </member>
              }
            </members>
            <sessions>
              {
                for $item in $items
                where normalize-space($item/chamber) = "House of Representatives"
                return
                  <session>
                    <number>{ normalize-space($item/number) }</number>
                    <type>{ normalize-space($item/type) }</type>
                    <period from="{ normalize-space($item/startDate) }" to="{ normalize-space($item/endDate) }" />
                  </session>
              }
            </sessions>
          </chamber>
          
          (: Tabla para Senate :)
          <chamber>
            <name>Senate</name>
            <members>
              {
                for $member in $senateMembers
                let $terms := $member/terms/item/item
                return
                  <member bioguideId="{ normalize-space($member/bioguideId) }">
                    <name>{ normalize-space($member/name) }</name>
                    <state>{ normalize-space($member/state) }</state>
                    <party>{ normalize-space($member/partyName) }</party>
                    <image_url>{ normalize-space($member/depiction/imageUrl) }</image_url>
                    {
                      for $term in $terms
                      let $senateTerm := normalize-space($term/startYear)
                      where normalize-space($term/chamber) = "Senate"
                      return
                        <period from="{ $senateTerm }" to="{ normalize-space($term/endYear) }" />
                    }
                  </member>
              }
            </members>
            <sessions>
              {
                for $item in $items
                where normalize-space($item/chamber) = "Senate"
                return
                  <session>
                    <number>{ normalize-space($item/number) }</number>
                    <type>{ normalize-space($item/type) }</type>
                    <period from="{ normalize-space($item/startDate) }" to="{ normalize-space($item/endDate) }" />
                  </session>
              }
            </sessions>
          </chamber>
          
        </chambers>
      </congress>
    </data>
  )

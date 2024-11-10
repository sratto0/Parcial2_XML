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
        <period from="{ $congress/startYear }" to="{ $congress/endYear }" />
        
        <chambers>
          (: Tabla para House of Representatives :)
          <chamber>
            <name>House of Representatives</name>
            <members>
              {
                for $member in $houseMembers
                return
                  <member bioguideId="{ $member/bioguideId }">
                    <name>{ $member/name }</name>
                    <state>{ $member/state }</state>
                    <party>{ $member/partyName }</party>
                    <image_url>{ $member/depiction/imageUrl }</image_url>
                    <period from="{ $member/terms/item/item/startYear }" to="{ $member/terms/item/item/endYear }" />
                  </member>
              }
            </members>
            <sessions>
              {
                for $item in $items
                where normalize-space($item/chamber) = "House of Representatives"
                return
                  <session>
                    <number>{ $item/number }</number>
                    <type>{ $item/type }</type>
                    <period from="{ $item/startDate }" to="{ $item/endDate }" />
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
                return
                  <member bioguideId="{ $member/bioguideId }">
                    <name>{ $member/name }</name>
                    <state>{ $member/state }</state>
                    <party>{ $member/partyName }</party>
                    <image_url>{ $member/depiction/imageUrl }</image_url>
                    <period from="{ $member/terms/item/item/startYear }" to="{ $member/terms/item/item/endYear }" />
                  </member>
              }
            </members>
            <sessions>
              {
                for $item in $items
                where normalize-space($item/chamber) = "Senate"
                return
                  <session>
                    <number>{ $item/number }</number>
                    <type>{ $item/type }</type>
                    <period from="{ $item/startDate }" to="{ $item/endDate }" />
                  </session>
              }
            </sessions>
          </chamber>
          
        </chambers>
      </congress>
    </data>
  )

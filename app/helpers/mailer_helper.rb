module MailerHelper

  # Bulletproof email button - http://buttons.cm/
  def mail_button(url, label, background_color: '#5BB62B', color: '#ffffff', border: 'none')
    haml =  <<-eos.strip_heredoc
      :plain
        <div><!--[if mso]>
          <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="#{url}" style="height:40px;v-text-anchor:middle;width:100%;" arcsize="13%" stroke="f" fillcolor="#{color}">
            <w:anchorlock/>
            <center>
          <![endif]-->
              <a href="#{url}"
        style="border:#{border};background-color: #{background_color}; border-radius:5px;color:#{color};display:inline-block;font-family:sans-serif;font-size:13px;font-weight:bold;line-height:40px;text-align:center;text-decoration:none;width:100%;-webkit-text-size-adjust:none;">#{label}</a>
          <!--[if mso]>
            </center>
          </v:roundrect>
        <![endif]--></div>
    eos
    Haml::Engine.new(haml).render
  end

  def mail_asset_url(asset)
    "http://assets0.folyo.me/emails/#{asset}"
  end

  def skill_image_path(skill)
    image_name = case(skill)
      when :icon_design    then 'icondesign.png'
      when :logo_design    then 'logodesign.png'
      when :mobile_design  then 'mobileesign.png'
      when :web_design     then 'webdesign.png'
      when :UI_design      then 'uidesign.png'
      when :UX_design      then 'ux.png'
      when :print_design   then 'printdesign.png'
      when :illustration   then 'illustration.png'
    end
    mail_asset_url "skills/#{image_name}"
  end

end

module MailerHelper

  # Bulletproof email button - http://buttons.cm/
  def mail_button(url, label, color: '#5BB62B')
    haml =  <<-eos.strip_heredoc
      :plain
        <div><!--[if mso]>
          <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="#{url}" style="height:40px;v-text-anchor:middle;width:100%;" arcsize="13%" stroke="f" fillcolor="#{color}">
            <w:anchorlock/>
            <center>
          <![endif]-->
              <a href="#{url}"
        style="background-color:#{color};border-radius:5px;color:#ffffff;display:inline-block;font-family:sans-serif;font-size:13px;font-weight:bold;line-height:40px;text-align:center;text-decoration:none;width:100%;-webkit-text-size-adjust:none;">#{label}</a>
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

end
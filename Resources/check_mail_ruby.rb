require 'net/imap'
require 'tmail'

class MailAlertsClass
  @imap_server=1
  @messages_msg_dict={}
  
  def imap_login(imapusername,imappassword,imapserver,imapusessecure,imapport)
     begin
       @imap_server = Net::IMAP.new(imapserver,imapport,imapusessecure)
       @imap_server.login(imapusername,imappassword)
       @imap_server.select('INBOX')
       return true
     rescue
       return false
     ensure
     end
   end
  
  def checkemail()
    begin
      @messages_msg_dict={}
      return @imap_server.search(["UNSEEN"])
    rescue
      return false
    ensure
    end
  end
  
  def fetch_message_content(message_id)
    @messages_msg_dict[message_id]=@imap_server.fetch(message_id, "(UID RFC822)")[0]
    return true
  end

  def return_message_details_and_body(message_id,bodytypetoreturn)
    return_dictionary = {}
    body_string=@messages_msg_dict[message_id].attr["RFC822"]
    email_structure = TMail::Mail.parse(body_string)
    #return_dictionary['UID']=@messages_msg_dict[message_id].attr["UID"]
    return_dictionary['from']=email_structure.friendly_from
    return_dictionary['subject']=email_structure.subject
    return_dictionary['ifmultipart']=email_structure.multipart?
    return_dictionary['body']=""
    if bodytypetoreturn=="dontshow" then
      return return_dictionary
    end
    if bodytypetoreturn=="showfullhtml" then
      required_content_type="text/html"
    end
    if bodytypetoreturn=="showplainonly" then
      required_content_type="text/plain"
    end
    if email_structure.multipart? then
      email_structure.parts.each do |m|
        if m.content_type==required_content_type
          return_dictionary['body']=m.body
        end
      end
    else
      return_dictionary['body']=email_structure.body
    end
    return return_dictionary
  end
  
  def mark_message_as_read(message_id)
    @imap_server.store(message_id, "+FLAGS", [:Seen])
  end

  def imap_logout()
    @messages_msg_dict={}
    @imap_server.logout()
  end
  
end
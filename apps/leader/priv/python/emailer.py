default_greating = ",\n"+"\n"+"It was a pleasure to meet you at White Label Las Vegas last week! We appreciate you taking the time to visit the ABA Packaging booth and thank you for your interest in our products and services."
default_subject = " WHITE LABEL LV 2020 FOLLOW UP FROM ABA PACKAGING"
default_conclusion = "\nLooking forward to working with you!\nKindest,\n"
ca_conclusion = "\nIn addition, please note I handle West Coast sales for ABA and work out of the SoCal area once a month. If I can be of service to you in any way, please do not hesitate to contact me. I am always happy to come by your offices or you are welcome to come to our showroom in Playa Vista."


def save_draft(lead, subject, body):
    from independentsoft.msg import Message
    from independentsoft.msg import Recipient
    from independentsoft.msg import ObjectType
    from independentsoft.msg import DisplayType
    from independentsoft.msg import RecipientType
    from independentsoft.msg import MessageFlag
    from independentsoft.msg import StoreSupportMask
    import os



    message = Message()
# # TODO: strip earlier
    contact = Recipient()
    contact.address_type = "SMTP"
    contact.display_type = DisplayType.MAIL_USER
    contact.object_type = ObjectType.MAIL_USER
    # uses name if availiable, company if not, and email if none availiable
    if lead[3] is not None:
        if lead[4] is not None:
            contact.display_name = lead[3].strip() + " " + lead[4].strip()
        else:
            contact.display_name = lead[3].strip()
    elif lead[2] is not None:
        contact.display_name = lead[2].strip()
    else:
        contact.display_name = lead[6].strip()

    contact.email_address = lead[6].strip()
    contact.recipient_type = RecipientType.TO

    veronica = Recipient()
    veronica.address_type = "SMTP"
    veronica.display_type = DisplayType.MAIL_USER
    veronica.object_type = ObjectType.MAIL_USER
    veronica.display_name = "veronica"
    veronica.email_address = "veronica@abapackaging.com"
    veronica.recipient_type = RecipientType.CC

    message.subject = subject
    message.body = body
    message.display_to = contact.display_name
    message.display_cc = veronica.display_name
    message.recipients.append(contact)
    message.recipients.append(veronica)
    message.message_flags.append(MessageFlag.UNSENT)
    message.store_support_masks.append(StoreSupportMask.CREATE)

    # build file name
    if lead[2] is not None: #uses company name
        file_name = lead[2]
    elif lead[3] is not None: # if no company name uses contacts name
        file_name = lead[3]
    else:  # if nothing else availiable uses email
        file_name = lead[6]

    os.chdir('/Users/mechimcook/dev/Python-fun/leader/output/emails/')
    message.save(file_name + ".msg")

    # Display Status
    print("Draft saved Successfully.")


def email_west(lead):
        # getting the email subject
    if lead[2] is not None: #2 = company name
        subject = lead[2] + default_subject
    else:
        subject = default_subject

    # getting the email greating
    if lead[3] is not None: #if we have a first name
        greating = "Hi " + lead[3].strip() + default_greating
    elif lead[2] is not None: #if we have a company name
        greating = "Hi " + lead[2].strip() + default_greating
    else: # niether we just say hello
        greating = "Hello" + default_greating

    # build body
    topic = west_body(lead)

    # getting conclusion
    if lead[10] == 'CA': #if they are in CA
        conclusion = ca_conclusion + default_conclusion
    else:
        conclusion = default_conclusion

    body = greating + topic + conclusion

    save_draft(lead, subject, body)
    print(subject)
    print(body)
    print(lead)



def west_body(lead):
    default_topic_intro = "We are currently working to action everyone's requests from the show and will do our very best to get any samples, pricing, and catalogs out to you as quickly as possible. "
    default_topic_body = "ABA Packaging now offers a wide variety of eco-friendly primary packaging options including Aluminum bottles and PCR bottles, jars and tubes. You can always see our many stock products at www.abapackaging.com."
    # additional topics
    topic_catalog = "We also have many new additions to our catalog and you will be receiving one in the mail in the coming weeks. "
    topic_jar = "Many of our offerings can be found on our website - link as follows: https://abapackaging.com/collections/jar-collection"


        # build the body
    if lead[11] is None: #if we have a first name
        body = default_topic_intro + default_topic_body
    else: # niether we just say hello
        search_terms = lead[11].upper().split(" ")
        body = default_topic_intro + default_topic_body


    return body

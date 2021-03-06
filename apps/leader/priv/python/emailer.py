
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


    html_body = "<html><body><b>" + body + "</b></body></html>"
    html_body_with_rtf = "{\\rtf1\\ansi\\ansicpg1252\\fromhtml1 \\htmlrtf0 " + html_body + "}"
    rtf_body = html_body_with_rtf.encode("utf_8")


    # todo only use firstname else say good afternoon
    if lead.get('first_name') != 'nil':
        if lead.get('last_name') != 'nil':
            contact.display_name = lead.get('first_name').strip() + " " + lead.get('last_name').strip()
        else:
            contact.display_name = lead.get('first_name').strip()
    elif lead.get('company') != 'nil':
        contact.display_name = lead.get('company').strip()
    else:
        contact.display_name = lead.get('email').strip()

    contact.email_address = lead.get('email').strip()
    contact.recipient_type = RecipientType.TO

    veronica = Recipient()
    veronica.address_type = "SMTP"
    veronica.display_type = DisplayType.MAIL_USER
    veronica.object_type = ObjectType.MAIL_USER
    veronica.display_name = "veronica"
    veronica.email_address = "veronica@abapackaging.com"
    veronica.recipient_type = RecipientType.CC

    message.subject = subject
    message.body_html_text = html_body
    message.body_rtf = rtf_body
    message.display_to = contact.display_name
    message.display_cc = veronica.display_name
    message.recipients.append(contact)
    message.recipients.append(veronica)
    message.message_flags.append(MessageFlag.UNSENT)
    message.store_support_masks.append(StoreSupportMask.CREATE)

    # build file name
    if lead.get('company') is not 'nil': #uses company name
        file_name = lead.get('company')
    elif lead.get('first_name') is not 'nil': # if no company name uses contacts name
        file_name = lead.get('first_name')
    else:  # if nothing else availiable uses email
        file_name = lead.get('email')

    os.chdir('/Users/mechimcook/dev/')
    message.save(file_name + ".msg")
    # Display Status
    return "Draft saved Successfully."


def email_west(lead_keys, lead_values, orders_keys, orders_values):
    # order_values is a list of lists representing the orders values
    lead = {}
    orders= []
    count = 0
    for key in lead_keys:
        if isinstance(lead_values[count], bytes):
            lead[key.decode('utf-8')] = lead_values[count].decode('utf-8')
        count += 1

    for value_set in orders_values:

        count = 0
        order = {}
        for key in orders_keys:
            if isinstance(value_set[count], list):
                new_value_list = []
                value_list = filter(lambda a: a != b'',  value_set[count])
                for value in value_list:
                    new_value_list.append(value.decode('utf-8'))
                order[key.decode('utf-8')] = new_value_list
            else:
                order[key.decode('utf-8')] = value_set[count].decode('utf-8')
            count += 1
        orders.append(order)
    lead.update({"orders": orders})


    default_subject = " WHITE LABEL LV 2020 FOLLOW UP FROM ABA PACKAGING"
    default_conclusion = "<br>Looking forward to working with you!<br>Kindest,<br>"
    ca_conclusion = "<br>In addition, please note I handle West Coast sales for ABA and work out of the SoCal area once a month. If I can be of service to you in any way, please do not hesitate to contact me. I am always happy to come by your offices or you are welcome to come to our showroom in Playa Vista."

        # getting the email subject
    if lead.get('company') != 'nil': #"company" = company name
        subject = lead.get('company') + default_subject
    else:
        subject = default_subject

    # getting the email greating
    if lead.get('first_name') != 'nil': #if we have a first name
        greating = "Hi " + lead.get('first_name').strip() + ",<br>"
    else: # niether we just say hello
        greating = "Good Afternoon,<br>"

    # build body
    topic = west_body(lead)

    # getting conclusion
    if lead.get('state') == 'CA': #if they are in CA
        conclusion = ca_conclusion + default_conclusion
    else:
        conclusion = default_conclusion

    body = greating + topic + "<p>" + conclusion + "</p>"


    save_draft(lead, subject, body)


def build_order_body(order, orders_number):
    quantity = order.get("Quantity")
    volume = order.get("Volume")
    materials = order.get("Materials")
    products = order.get("Products")

    if orders_number == 0:
        order_info = "I see you're interested in "
    else:
        order_info = "As well as"


    if quantity != "":
        order_info += quantity + " of our "
    else:
        order_info += "our "

    if volume != "":
        order_info += volume + " "

    if len(materials) == 1:
        order_info += materials[0] + " "
    elif len(materials) == 2:
        order_info += materials[0] + "s and " + materials[1] and "s"

    if (len(products) == 0) and (quantity != ""):
        order_info += "lines"
    elif len(products) == 1:
        order_info += products[0] + " "
    elif len(products) == 2:
        order_info += products[0] + " and " + products[1]
    elif len(products) == 3:
        order_info += products[0] + " and " + products[1] + " and " + products[2]
    else:
        order_info += " components"
    return "<p>" + order_info + ". We have many options that may be what you're looking for. Including [Add info on " + quantity + " " + volume + " ".join(materials) + " " + " ".join(products) + "]"

def west_body(lead):
    default_greating = "It was a pleasure to meet you at White Label Las Vegas last week! We appreciate you taking the time to visit the ABA Packaging booth and thank you for your interest in our products and services."
    default_topic_intro = "We are currently working to action everyone's requests from the show and will do our very best to get any samples, pricing, and catalogs out to you as quickly as possible. "
    default_topic_body = "ABA Packaging now offers a wide variety of eco-friendly primary packaging options including Aluminum bottles and PCR bottles, jars and tubes. You can always see our many stock products at www.abapackaging.com."
    # additional topics
    topic_catalog = "We also have many new additions to our catalog and you will be receiving one in the mail in the coming weeks. "

    body = "<p>" + default_greating + default_topic_intro + default_topic_body + topic_catalog + "</p>"

    if lead.get('orders') != []:
        count = 0
        for order in lead.get('orders'):
            body += build_order_body(order, count)
            count += 1
    return body

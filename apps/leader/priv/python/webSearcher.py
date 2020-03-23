def find_contact(lead):
    # search company site and find contact contact name
    # plug info we do have into google
    # check linkedin/facebook/first result
    first_name = ''
    last_name = ''
    lead[3] = first_name
    lead[4] = last_name
    return lead

def find_number(lead):
            # start with a company search then look for blerb with phone
        # plug info we do have into google
        # check linkedin/facebook/website/first result
    number = ''
    lead[5] = number
    return lead

def find_email(lead):
        # start with a company search then look for blerb with email
        # plug info we do have into google
        # check linkedin/facebook/website/first result
    email = ''
    lead[6] = email
    return lead

def find_state(lead):
    # to find missing state would need to
    # 1. google company name
    # 2. look for info blerb with Address
    # 3. if no address look for website/facebook/instagram could end there and give this to xl
    # look on facebook if there is one then check intagram then check website then check website/about us or address
    state = ''
    lead[10] = state
    return lead


def get_missing(lead):
    # search google for company site and find find_contact
    if lead[3] is None: #3 = first name
        lead = find_contact(lead)
        pass
    if lead[5] is None: #5 = Phone Number
        lead = find_number(lead)
        pass
    print(lead[10])
    if lead[6] is None: #6 = email
        lead = find_email(lead)
        pass
    if lead[10] is None: #10 = state
        lead = find_state(lead)
        pass
    return lead

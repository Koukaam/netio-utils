#!/usr/bin/env python
# lists states and consuption for NETIO4 sockets
# run as python get_consumption.py <address> <username> <password>

from xml.etree import ElementTree
import httplib, sys

class BaseRequest(object):
    inner = None # inner XML
    def wrapped(self, sessionId=None):
        attrs = ' sessionID="%s"' % sessionId if sessionId != None else ''
        return '<request%s>%s</request>' % (attrs, self.inner)

class RequestError(Exception):
    pass

class Login(BaseRequest):
    def __init__(self, username, password):
        self.inner = ('<session action="login"><credentials><username>%s</username>' \
            + '<password>%s</password></credentials></session>') % (username, password)

class Logout(BaseRequest):
    inner = '<session action="logout"/>'

class GetSystemVariables(BaseRequest):
    inner = '<device action="get"><selector><name>system</name></selector><sections><variables/></sections></device>'

class Netio(object):
    def __init__(self,address, username, password):
        self.address = address
        self.username = username
        self.password = password

class XmlConnection(object):
    sessionId = None
    
    def __init__(self, box):
        self.box = box
        login = Login(self.box.username, self.box.password)
        response = self.send(login)
        self.sessionId = response.findtext("sessionID") 
    
    def send(self, request):
        """ Send one request to box or target if specified"""
        conn = httplib.HTTPConnection(self.box.address)
        conn.request("POST", "/xml",
            request.wrapped(self.sessionId),
            {'Accept': 'application/xml', 'Content-Type': 'application/xml; charset=utf-8'}
        )
        response = conn.getresponse()
        if response.status != 200:
            raise RequestError("HTTP error: %s" % response.reason)
        
        xmlResponse = ElementTree.fromstring(response.read())
        error = xmlResponse.find('error')
        if int(error.attrib['code']) != 0:
            raise RequestError(error.findtext('message'))
        return xmlResponse
    
    def close(self):
        self.send(Logout())

def get_vars(box):
    xmlConn = XmlConnection(box)
    response = xmlConn.send(GetSystemVariables())
    xmlConn.close()
    
    out = {}
    for var in response.findall('device/variables/var'):
        out[var.attrib['key']] = var.text
    return out

if __name__ == '__main__':
    if len(sys.argv) != 4:
        raise Exception('we need three arguments: address, username, and password')
    
    box = Netio(*sys.argv[1:])
    variables = get_vars(box)
    for output in [1,2,3,4]:
        line = [output, variables.get('output%s_state' % output, 'X'), variables.get('output%s_consumption' % output, 'X') + ' W']
        print '\t'.join(map(unicode, line))

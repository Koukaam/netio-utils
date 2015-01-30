#!/usr/bin/env python
# gets/set system configuration variables on NETIO4
# run as python system.py <address> <username> <password> get <variable> [<variable> ...]
#     or python system.py <address> <username> <password> set <variable>=<value> [<variable>=<value> ...]
from __future__ import print_function

from xml.etree import ElementTree
from xml.sax.saxutils import escape
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

class GetVariables(BaseRequest):
    def __init__(self, variables):
        """ get values of variables given in the list """
        self.inner = '<system action="get">%s</device>' % ''.join(['<%s/>' % v for v in variables])
    
class SetVariables(BaseRequest):
    def __init__(self, newValues):
        """ set values of variables given in the list """
        self.inner = '<system action="set">%s</device>' % ''.join(['<%s>%s</%s>' % (k, escape(v), k) for k, v in newValues.items()])

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
        
        responseText = response.read()
        xmlResponse = ElementTree.fromstring(responseText)
        error = xmlResponse.find('error')
        if int(error.attrib['code']) != 0:
            print(responseText, file=sys.stderr)
            raise RequestError(error.findtext('message'))
        return xmlResponse
    
    def close(self):
        self.send(Logout())
    
    @staticmethod
    def sendOne(box, request):
        """ sends one request, returns response """
        conn = XmlConnection(box)
        response = conn.send(request)
        conn.close
        return response

class Netio(object):
    def __init__(self, address, username, password):
        self.address = address
        self.username = username
        self.password = password
    
    def getVariables(self, variables):
        response = XmlConnection.sendOne(self, GetVariables(variables))
        
        out = {}
        for var in response:
            if var.tag == 'error':
                continue
            out[var.tag] = var.text
        return out
    
    def setVariables(self, newValues):
        XmlConnection.sendOne(self, SetVariables(newValues))

def printUsage():
    print('use as:')
    print('    system.py <address> <username> <password> get <variable> [<variable> ...]')
    print('    system.py <address> <username> <password> set <variable> <value> [<variable> <value> ...]')

if __name__ == '__main__':
    if len(sys.argv) < 6:
        printUsage()
        raise Exception('not enough arguments')
    
    box = Netio(*sys.argv[1:4])
    if sys.argv[4] == 'get':
        variables = box.getVariables(sys.argv[5:])
        for k, v in variables.items():
            print('%s=%s' % (k, v))
    elif sys.argv[4] == 'set':
        newValues = dict([item.split('=') for item in sys.argv[5:]])
        box.setVariables(newValues)
    else:
        raise Exception('don\'t know what to do')

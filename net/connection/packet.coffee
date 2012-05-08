# 
#
# Object to store the data for a packet. 
# A packet is what connections receive and send.
#
# Each packet will be sent as plain text with the following structure:
#
# separator + command + separator + fragment1+separator + ... + fragmentN
#
# e.g.
#
# **/login/simone/10:30AM/Good Mood**
#
#
# in the example above we have:
#
# * **separator** = /
#
# * **command** = login
#
# * **fragments** = [ 10:30AM , Good Mood]
#
#
#
#
#
class Packet
    #### constructor 
    # 
    # @separator = (**String**) separator to define the packet elements
    #
    # @command = (**String**) the command to be sent
    #
    # @messageFragments = (**Array**) list of fragments to append
    #
    constructor: (@separator, @command, @messageFragments) ->

    #### stringify
    #
    # Returns the packet in plain text format.
    #
    # return (String)
    #
    stringify: () =>

        eol = '\r\n'
        @separator + @command + @separator + @messageFragments.join(@separator) + eol


exports.Packet = Packet

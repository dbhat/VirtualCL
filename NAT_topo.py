""" Custom topology example

One switch with server and client on either side:

   host --- switch --- host

Adding the 'topos' dict with a key/value pair to generate our newly defined
topology enables one to pass in '--topo=mytopo' from the command line.
"""

from mininet.topo import Topo

class MyTopo( Topo ):
    "Simple topology example."

    def __init__( self ):
        "Create custom topo."

        # Initialize topology
        Topo.__init__( self )

        # Add hosts and switches
        client = self.addHost('h1', ip='192.168.0.2/24' )
        server = self.addHost('h2', ip='128.128.128.2/24' )
        Switch = self.addSwitch( 's3' )
        

        # Add links
        self.addLink( client, Switch )
        self.addLink( Switch, server )


topos = { 'mytopo': ( lambda: MyTopo() ) }

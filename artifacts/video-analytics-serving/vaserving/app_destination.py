'''
* Copyright (C) 2019-2020 Intel Corporation.
*
* SPDX-License-Identifier: BSD-3-Clause
'''

import abc

class AppDestination(metaclass=abc.ABCMeta):
    """Abstract class representing an application destination.

    When a pipeline with an application destination with a matching class name
    and pipeline type is created the implementation class is
    instantiated and passed the pipeline instance and request.

    When the pipeline produces a frame the process_frame method is
    called. It is called once for each frame the pipeline produces.

    When the pipeline has ended the finish method is called to allow
    the destination to dispose of any resources. Finish will be called
    exactly once per pipeline.

    """

    @abc.abstractmethod
    def __init__(self, request, pipeline):
        """Initializes DestinationSource

        Parameters
        ----------
        request : dict
          Dictionary of pipeline request. Contains source, destination and parameters.
          Beyond the required fields applications can extend the request to pass additional context.

        pipeline : GStreamerPipeline or FFMpegPipeline
          AppSource classes can make direct use of the Pipeline implementation classes
          to interact with the underlying pipeline framework.

        """

    @abc.abstractmethod
    def process_frame(self, frame):
        """Called when pipeline produces a frame.

        Parameters
        ----------
        frame : frame in pipeline specific format.

        """

    @abc.abstractmethod
    def finish(self):
        """Signals that the pipeline has ended."""

    @classmethod
    def create_app_destination(cls, request, pipeline):
        """Factory method for creating an AppDestination instance based on registered subclasses"""

        requested_destination = request.get("destination", {})
        requested_destination_type = requested_destination.get("type", None)
        requested_destination_class = requested_destination.get("class", None)
        destination_class = None

        if ((requested_destination_type == "application") and requested_destination_class):
            for destination_class in AppDestination.__subclasses__():
                if (destination_class.__name__ == requested_destination_class):
                    break
            else:
                destination_class = None

        if destination_class:
            try:
                return destination_class(request, pipeline)
            except Exception as error:
                raise Exception("Error Creating App Destination: {},"
                                "Exception: {} {}".format(requested_destination_class,
                                                          type(error),
                                                          error))
        return None

from .mode import Mode

class FreePlay(Mode):
    def __init__(self, map_name="fp_debugarea"):
        super().__init__()
        self.settings["map"] = map_name

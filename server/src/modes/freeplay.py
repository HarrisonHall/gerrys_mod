from .mode import Mode

class FreePlay(Mode):
    def __init__(self, map_name="fp_hub"):
        super().__init__()
        self.settings["map"] = map_name

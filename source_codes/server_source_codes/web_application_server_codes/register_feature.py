from component_classes.component import User
from database_codes.database import insertUserTable
def _register(user: User):

    success = insertUserTable(user=user)
    return success




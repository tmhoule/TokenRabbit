# TokenRabbit
GUI tool to Assign Secure Token to a user under 10.13

This tool will allow you to enter the name of an administrator with SecureToken assigned, then grant SecureToken to another user. 

Benefits:
  Checks the administrator actually does have SecureToken set
  Checks the target user does not have SecureTokenSet
  If the target user is an AD account, createmobileaccount will be invoked to SecureToken can be assigned.
  
  
Simply enter the Administrative name and password, then the target user's name and password.  

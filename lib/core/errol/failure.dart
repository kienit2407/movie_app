class AuthFailure {
  static String mapErrol (String message){
    print(message);
    if(message.contains('already registered')){
      return 'This account already created. Pls Choose anorther email?';
    } else if (message.contains('Password should')){
      return 'Password quite weak. Please enter stronger password';
    } else if (message.contains('Invalid login')){
      return 'Password or email not incorrect!. Pls try again';
    }
    return 'Have an errol occured. Please try again or contact with me:  0971161803';
  }
}
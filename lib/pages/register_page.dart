import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:walkingapp/components/my_button.dart';
import 'package:walkingapp/components/my_textfield.dart';

class RegisterPage extends StatelessWidget {
    // email and password text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // tap to go to login page
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  // Register method
  void register(){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body:Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo
          Icon(
            Icons.location_pin,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
            ),

          // Add spacer
          const SizedBox(height: 20,),

          // welcome message
          Text(
            "Create an account",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 16,
              ),
            ),

          // Add spacer
          const SizedBox(height: 30,),

          // email textfield
          MyTextField(
            hintText: "Email",
            obscureText: false,
            controller: _emailController,
          ),

           // Add spacer
          const SizedBox(height: 10,),

          // password textfield
          MyTextField(
            hintText: "Password",
            obscureText: true,
            controller: _passwordController,
          ),

          // Add spacer
          const SizedBox(height: 10,),

          // Confirm password textfield
          MyTextField(
            hintText: "Confirm password",
            obscureText: true,
            controller: _confirmPasswordController,
          ),

           // Add spacer
          const SizedBox(height: 10,),

          // login button
          MyButton(
            text: "Register",
            onTap: register,
            ),

          // Add spacer
          const SizedBox(height: 10,),

          // register now
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already a member? ",
                style: TextStyle(color: Theme.of(context).colorScheme.primary)
                ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "Login here", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                    )
                  ),
              ),
              ],
            )
          ],
        )
      )
    );
  }
}
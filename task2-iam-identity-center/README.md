# Task: Configure AWS Identity Center in your account. Create a new user and assign them a permission set using the predefined SecurityAudit job function policy

AWS IAM Identity Centre (formerly AWS SSO) is a service that provides a central place to manage workforce identities and their access to multiple AWS accounts and applications.

## Steps
- Navigate to IAM Identity Center from IAM dashboard or search for via the search bar. An instance of this service has to be enabled with organisations.
![csn_wk2](https://github.com/user-attachments/assets/9d0281fe-7dc4-4a27-846a-d1d7ff4f11f6)

![csn_wk2](./img/csn_wk2.png)

![csn1_wk2](./img/csn1_wk2.png)

- After enabling the IAM Identity Center, navigate to the dashboard and from the dashboard, navigate to AWS organisations to view the added account in the organisation.

![csn2_wk2](./img/csn2_wk2.png)

![csn3_wk2](./img/csn3_wk2.png)

- Edit the settings by specifying an instance name and the access portal URL (to something mor human-friendly).

![csn4_wk2](./img/csn4_wk2.png)

- Create a user and save the user's password details to be used in a later step (note that this can be viewed just once).

![csn5-2_wk2](./img/csn5-2_wk2.png)

![csn5-4_wk2](./img/csn5-4_wk2.png)

![csn5-5_wk2](./img/csn5-5_wk2.png)

- Next, create a permission set (permission set defines the level of access users in the IAM identity center have to their assigned AWS accounts), this can be found on the LHS of the IAM identity center.

![csn6_wk2](./img/csn6_wk2.png)

- I'll be using a **predefined permission set**, the SecurityAudit AWS managed policy.

![csn6-1_wk2](./img/csn6-1_wk2.png)

![csn6-2_wk2](./img/csn6-2_wk2.png)

- Navigate to AWS account to bind the permission set to the created user. Click on the **Assign users or groups** button.

![csn6-3_wk2](./img/csn6-3_wk2.png)

![csn6-8_wk2](./img/csn6-8_wk2.png)

![csn6-5_wk2](./img/csn6-5_wk2.png)

- After attaching the permission set to the user, I will login with the user (preferably on another browser to create a new session) using the access portal URL, to test the policy.

![csn7-1_wk2](./img/csn7-1_wk2.png)

![csn6-9_wk2](./img/csn6-9_wk2.png)

![csn7_wk2](./img/csn7_wk2.png)

- I tried to test by creating an IAM user and got the error below. This means that the  SecurityAudit permission set grants access to read security configurations metadata only and creating an IAM user does not fall under that.

![csn7-2_wk2](./img/csn7-2_wk2.png)

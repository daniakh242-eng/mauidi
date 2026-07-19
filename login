<?php
if (session_status() === PHP_SESSION_NONE) {
 session_start();
}

include 'config.php';

$message = "";

if($_SERVER['REQUEST_METHOD'] === 'POST'){

 $login_value = trim($_POST['login'] ?? '');
 $password = trim($_POST['password'] ?? '');

 if($login_value == "" || $password == ""){
 $message = "يرجى تعبئة جميع الحقول ❌";
 }else{

 if(filter_var($login_value, FILTER_VALIDATE_EMAIL)){
 $sql = "SELECT id, full_name, email, phone, password, role
 FROM users
 WHERE email = ?";
 }else{
 $sql = "SELECT id, full_name, email, phone, password, role
 FROM users
 WHERE phone = ?";
 }

 $stmt = mysqli_prepare($conn, $sql);
 mysqli_stmt_bind_param($stmt, "s", $login_value);
 mysqli_stmt_execute($stmt);
 mysqli_stmt_store_result($stmt);

 if(mysqli_stmt_num_rows($stmt) > 0){

 mysqli_stmt_bind_result($stmt, $user_id, $full_name, $email, $phone, $db_password, $role);

 $matched_user = null;

 while(mysqli_stmt_fetch($stmt)){

 if($password == $db_password || password_verify($password, $db_password)){

 $current_role = strtolower(trim($role ?? 'user'));

 $current_user = [
 'id' => $user_id,
 'full_name' => $full_name,
 'email' => $email,
 'phone' => $phone,
 'role' => $current_role
 ];

 if($current_role == 'admin'){
 $matched_user = $current_user;
 break;
 }

 if($matched_user == null){
 $matched_user = $current_user;
 }
 }
 }

 if($matched_user != null){

 $_SESSION['user_id'] = $matched_user['id'];
 $_SESSION['user_name'] = $matched_user['full_name'];
 $_SESSION['user_email'] = $matched_user['email'];
 $_SESSION['user_phone'] = $matched_user['phone'];
 $_SESSION['user_role'] = $matched_user['role'];

 if($matched_user['role'] == 'admin'){
 header("Location: admin/dashboard.php");
 exit();
 }else{
 header("Location: index.php");
 exit();
 }

 }else{
 $message = "بيانات تسجيل الدخول غير صحيحة ❌";
 }

 }else{
 $message = "بيانات تسجيل الدخول غير صحيحة ❌";
 }
 }
}
?>

 
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<​meta charset="UTF-8">
<title>تسجيل الدخول | موعدي</title>

<link rel="stylesheet" href="css/style.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

</head>

<body class="login-page">

<section class="login-hero">
 <div class="login-hero-content">
 <h1>تسجيل الدخول</h1>
 <p>ادخل إلى حسابك لمتابعة المواعيد والخدمات الطبية بسهولة.</p>
 </div>
</section>

<section class="login-section">

 <div class="login-card">

 <div class="login-card-icon">
 <i class="fa-solid fa-lock"></i>
 </div>

 <h2>مرحباً بعودتك</h2>
 <p>يرجى إدخال البريد الإلكتروني أو رقم الهاتف وكلمة المرور.</p>

 <form method="POST" class="login-form-pro">

 <?php if($message != ""){ ?>
 <div class="login-error-msg">
 <?php echo $message; ?>
 </div>
 <?php } ?>

 <div class="login-group">
 <label>البريد الإلكتروني أو رقم الهاتف</label>

 <div class="login-input-box">
 <i class="fa-solid fa-user"></i>

 <input 
 type="text" 
 name="login" 
 placeholder="أدخل البريد الإلكتروني أو رقم الهاتف" 
 required
 >
 </div>
 </div>

 <div class="login-group">
 <label>كلمة المرور</label>

 <div class="login-input-box">
 <i class="fa-solid fa-lock"></i>

 <input 
 type="password" 
 name="password" 
 id="passwordInput" 
 placeholder="أدخل كلمة المرور" 
 autocomplete="current-password" 
 required
 >

 <i class="fa-regular fa-eye toggle-password" id="togglePassword"></i>
 </div>
 </div>

 <div class="login-options">
 <label>
 <input type="checkbox">
 تذكرني
 </label>

<a href="forgot_password.php">نسيت كلمة المرور؟</a>
 </div>

 <button type="submit" class="login-submit-btn">
 تسجيل الدخول
 </button>

 <div class="create-account-link">
 ليس لديك حساب؟
 <a href="register.php">إنشاء حساب جديد</a>
 </div>

 </form>

 </div>

</section>

<​script>
const passwordInput = document.getElementById("passwordInput");
const togglePassword = document.getElementById("togglePassword");

if(togglePassword){
 togglePassword.addEventListener("click", function () {

 if (passwordInput.type === "password") {
 passwordInput.type = "text";

 togglePassword.classList.remove("fa-eye");
 togglePassword.classList.add("fa-eye-slash");

 } else {
 passwordInput.type = "password";

 togglePassword.classList.remove("fa-eye-slash");
 togglePassword.classList.add("fa-eye");
 }

 });
}
<​/script>

</body>
</html>

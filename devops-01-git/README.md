# devops-netology
В этом файле .gitignore мы пропописываем все, что должно игнорироваться: слова, буквосочетания, расширения и т.д.
В файле terraform.gitignore будут игнорироваться все файлы в папках
**/.terraform/*
и файлы вида
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
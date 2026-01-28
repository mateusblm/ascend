import com.android.build.gradle.BaseExtension

// 1. Definição de plugins (Apenas uma vez)
plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.gms.google-services") version "4.4.0" apply false // Mantemos essa pois o Flutter não a traz por padrão
}
// 2. Configuração de Repositórios
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. Redirecionamento do Build Directory (Padrão do Flutter)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Correção de Namespace para bibliotecas antigas (Isar, etc)
    plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        val android = project.extensions.getByName("android") as BaseExtension
        if (android.namespace == null) {
            android.namespace = project.group.toString()
        }
    }
}

// 4. Dependência de Avaliação
subprojects {
    project.evaluationDependsOn(":app")
}

// 5. Tarefa de Clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
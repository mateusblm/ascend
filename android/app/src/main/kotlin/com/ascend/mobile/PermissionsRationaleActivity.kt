package com.ascend.mobile

import android.app.Activity
import android.os.Bundle
import android.widget.TextView

class PermissionsRationaleActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(
            TextView(this).apply {
                text = "Ascend usa Health Connect apenas para validar sessoes competitivas iniciadas pelo usuario. " +
                    "Os dados lidos sao duracao, distancia e identificador da sessao necessarios para evitar reutilizacao de evidencia."
                textSize = 16f
                setPadding(48, 48, 48, 48)
            }
        )
    }
}

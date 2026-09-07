import { Component } from '@angular/core';

interface Paso {
  numero: string;
  titulo: string;
  descripcion: string;
}

@Component({
  selector: 'app-como-funciona',
  imports: [],
  templateUrl: './como-funciona.html',
  styleUrl: './como-funciona.css',
})
export class ComoFunciona {
  protected readonly pasos: Paso[] = [
    {
      numero: '01',
      titulo: 'Estaciones IDEAM miden lluvia',
      descripcion:
        'El catálogo oficial de estaciones pluviométricas e hidrométricas del IDEAM registra lluvia y nivel de los ríos en el Chocó.',
    },
    {
      numero: '02',
      titulo: 'Se acumula la lluvia reciente',
      descripcion:
        'Cauce suma la lluvia de los últimos 7, 15 y 30 días por municipio — la misma variable que ha precedido a las inundaciones reales documentadas en la región.',
    },
    {
      numero: '03',
      titulo: 'Un modelo entrenado con eventos reales estima el riesgo',
      descripcion:
        'Un modelo estadístico, entrenado contra inundaciones reales documentadas (prensa, OCHA) y precipitación histórica real, clasifica el riesgo en bajo, medio, alto o crítico.',
    },
    {
      numero: '04',
      titulo: 'El resultado se actualiza cada hora',
      descripcion:
        'El mapa, el panel y el histórico de cada municipio se recalculan automáticamente — nunca es un número fijo.',
    },
  ];
}

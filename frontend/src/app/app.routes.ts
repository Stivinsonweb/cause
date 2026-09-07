import { Routes } from '@angular/router';

import { Inicio } from './pages/inicio/inicio';
import { Moderacion } from './pages/moderacion/moderacion';

export const routes: Routes = [
  { path: '', component: Inicio },
  { path: 'moderacion', component: Moderacion },
];

import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { HomePageComponent } from './ui/home-page/home-page.component';
import { QueueComponent } from './ui/queue/queue.component';

const routes: Routes = [
  { path: '', component: HomePageComponent },
  { path: 'queue/:companyKey', component: QueueComponent, pathMatch: 'full' },  
];

@NgModule({
  imports: [RouterModule.forRoot(routes, {useHash: true})],
  exports: [RouterModule]
})
export class AppRoutingModule { }

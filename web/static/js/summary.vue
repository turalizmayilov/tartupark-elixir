<template>
    <div class="table-responsive">
        <h1 style="text-align:center;">Booking Summary</h1>
        <table class="table">
            <thead>
                <tr>
                    <th>Booking Start Time</th>
                    <th>Booking End Time</th>
                    <!-- <th>Payment Time</th> -->
                    <th>Payment Type</th>
                    <th>Payment Number</th>
                    <th>Booking Cost</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="booking in bookings" :key="booking.booking_id">
                    <td>{{ (booking.startDateTime).substring(11, 16) + " " + (booking.startDateTime).substring(8, 10) + "/" + (booking.startDateTime).substring(5, 7) + "/" + (booking.startDateTime).substring(0, 4) }}</td>
                    <td>{{ (booking.endDateTime != null) ? (booking.endDateTime).substring(11, 16) + " " + (booking.endDateTime).substring(8, 10) + "/" + (booking.endDateTime).substring(5, 7) + "/" + (booking.endDateTime).substring(0, 4) : null }}</td>
                    <!-- <td>{{ booking.paymentTime }}</td> -->
                    <td>{{ booking.paymentType }}</td>
                    <td>{{ (booking.payment != null) ? booking.payment.payment_code : null }}</td>
                    <td>{{ (booking.payment != null) ? (booking.payment.cost).toFixed(2) : (booking.cost != null) ? (booking.cost).toFixed(2) : null}}</td>
                    <td class="text-right">
                        <button type="submit" v-if="'lt' == booking.startAndCurrentTimeComparison && booking.paymentType == 'Real Time' && booking.endDateTime == null" style="width: 100px;" class="btn btn-info btn-xs" id="btn_end" v-on:click="endParking(booking.booking_id)">End Parking</button>
                        <button v-if="booking.endDateTime != null && booking.payment == null && !!booking.cost && booking.cost>0  " style="width: 100px;" class="btn btn-success btn-xs" @click="showModal=true" v-on:click="sendInfoToPopUp(booking.booking_id, booking.cost)" id="btn_pay2">Pay</button>
                        <button type="submit" v-if="'gt' == booking.startAndCurrentTimeComparison && booking.payment == null" style="width: 100px;" class="btn btn-danger btn-xs" id="btn_cancel" v-on:click="cancelBooking(booking.booking_id)">Cancel Booking</button>
                    </td>
                </tr>
            </tbody>
        </table>

        <my-modal v-show="showModal" @close="showModal=false">
            <form class="col-md-10 col-md-offset-1" style="padding:0">
                <div class="form-group col-md-12">
                    <input type="text" class="form-control" id="cardNumber" v-model="cardNumber" placeholder="Card Number" contenteditable="false">
                </div>
                <p style="text-align:center;">Expiration</p>
                <div class="form-group col-md-6">
                    <input type="text" class="form-control" id="cardMonth" v-model="cardMonth" placeholder="Month" contenteditable="false">
                </div>
                <div class="form-group col-md-6">
                    <input type="text" class="form-control" id="cardYear" v-model="cardYear" placeholder="Year" contenteditable="false">
                </div>
                <div class="form-group col-md-12">
                    <input type="text" class="form-control" id="cardPAC" v-model="cardPAC" placeholder="Premier Access Code">
                </div>
                <div class="clearfix"></div>
            </form>

            <div class="row text-center">
                <hr>
                <button type="submit" class="btn btn-primary col-md-8 col-md-offset-2" id="btn_pay" v-on:click="payParking()">Pay</button>
                <br class="">
            </div>
        </my-modal>
        <router-link class="btn btn-default" :to="{ name: 'main'}" style="margin: 10px auto;">Back</router-link>
    </div>
</template>

<script>
import axios from "axios";
import socket from "./socket";
import auth from "./auth";
import moment from "moment";


export default {
    data: function() {
        return {
            bookings: [],
            selectedBookingForUpdate: null,
            bookingIdToPay: null,
            showModal: false,
            cardNumber: null,
            cardMonth: null,
            cardYear: null,
            cardPAC: null,
            costToPAy: null
        }
    },
    methods: {
        endParking: function(booking_id){
            axios.patch("/api/bookings/"+ booking_id,
            {endDateTime: moment(new Date()).format('YYYY-MM-DDTHH:mm:ss.SSS') + "Z"},
            {headers: auth.getAuthHeader()})
            .then(response => {
                console.log(response.data);
                document.getElementById("btn_modal").click();
                alert(response.data.msg);
                this.getSummary();
            })
            .catch(error => {
                console.log(error);
            });
        },
        cancelBooking: function(bookingId){
            // console.log("booking id: " + bookingId);
            axios.delete("/api/bookings/"+bookingId,
            {headers: auth.getAuthHeader()})
            .then(response => {
                console.log(response.data.msg);
                alert(response.data);
                this.getSummary();
            })
            .catch(error => {
                console.log(error);
            });
        },
        sendInfoToPopUp: function(bookingId, cost){
            this.bookingIdToPay = bookingId;
            this.costToPay = cost;
        },
        payParking: function(booking_id, cost){
          // console.log("PAYMENT PARAMS: id:" + this.bookingIdToPay + " cost:" + this.costToPay);
          axios.post("/api/payments/"+this.bookingIdToPay,
          {cost: this.costToPay},
          {headers: auth.getAuthHeader()})
          .then(response => {
              console.log(response.data.msg);
              document.getElementById("btn_modal").click();
              alert(response.data.msg);
              this.getSummary();
          })
          .catch(error => {
              console.log(error);
          });
        },
        getSummary: function(){
            axios.get("/api/bookings/summary",
            {headers: auth.getAuthHeader()})
            .then(response => {
                console.log(response.data.bookings);
                this.bookings = response.data.bookings;
            })
            .catch(error => {
                console.log(error);
            });
        }
    },
    mounted: function() {
        this.getSummary();
        if (auth.socket) {
            var channel = auth.getChannel("customer:");
            channel.join()
                .receive("ok", resp => { console.log("Joined successfully", resp) })
                .receive("error", resp => { console.log("Unable to join", resp) });

            channel.on("requests", payload => {
                this.messages = payload.msg;
                // document.getElementById('put-message-here').innerHTML = payload.msg;
            });
        }
    }
}
</script>


<style>
table {
  border-collapse: separate;
  border-spacing: 0 5px;
}

thead th {
  background-color: #006DCC;
  color: white;
}

tbody td {
  background-color: #EEEEEE;
}

tr td:first-child,
tr th:first-child {
  border-top-left-radius: 6px;
  border-bottom-left-radius: 6px;
}

tr td:last-child,
tr th:last-child {
  border-top-right-radius: 6px;
  border-bottom-right-radius: 6px;
}

.table>thead>tr>th {
    vertical-align: bottom;
    border-bottom: 2px solid #ddd;
    color: white;
}
</style>

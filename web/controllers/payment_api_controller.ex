defmodule Tartupark.PaymentAPIController do
  use Tartupark.Web, :controller
  alias Tartupark.{Payment, Booking}

  def create(conn, %{"bookingId" => booking_id, "cost" => cost}) do
    case is_float cost do
      true -> cost = cost
      false -> cost = cost |> Float.parse |> elem(0)
    end

    booking = Repo.get(Booking, booking_id)
    payment_code = random_string(21)
    payment = Ecto.build_assoc(booking, :payment, %{cost: cost, payment_code: payment_code})
    real_cost = payment_calculate(booking)
    if real_cost == cost do
      case Repo.insert payment do
        {:ok, _struct}       -> conn
                                |> put_status(201)
                                |> json(%{msg: "Payment has been done.", payment_id: payment.id})
        {:error, _changeset} -> conn
                                 |> put_status(400)
                                 |> json(%{msg: "Payment error has occure."})
      end
    else
      conn
      |> put_status(400)
      |> json(%{msg: "Wrong cost value given #{cost}, but should be #{real_cost}."})
    end
  end

  def update(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{msg: "Notification sent to the customer"})
  end

  def random_string(length) do
    alpha = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]
    payment_code = ""
    payment_code = for _x <- 1..13, do: payment_code <> Enum.random(alpha)
    payment_code = Enum.join(payment_code)
    payment_code = "EST" <> payment_code
    case Repo.get_by(Payment, payment_code: payment_code) do
      nil -> payment_code
      _ -> random_string(length)
    end
  end

  def payment_calculate(booking) do
     booking = booking |> Repo.preload(place: [:zone])
     start_date = booking.startDateTime
     end_date = booking.endDateTime
     payment_type = booking.paymentType
     cost_hourly_per_second = booking.place.zone.costHourly / 3600
     cost_real_time_per_second = booking.place.zone.costRealTime / 5*60
     case payment_type do
       "Hourly" -> (NaiveDateTime.diff(end_date, start_date)*cost_hourly_per_second) |> Float.round(2)
       "Real Time" -> (NaiveDateTime.diff(end_date, start_date)*cost_real_time_per_second) |> Float.round(2)
     end
  end
end

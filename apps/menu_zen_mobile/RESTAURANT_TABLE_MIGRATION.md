The new example of return of the API:

GET /tables



[
{
"name": "T1",
"restaurant_id": 1,
"status": "assigned",
"server_id": 6,
"waiting_since": null,
"seats": null,
"id": 1,
"server": {
"id": 6,
"username": "server2"
},
"active_reservation": null
},
{
"name": "T2",
"restaurant_id": 1,
"status": "free",
"server_id": null,
"waiting_since": null,
"seats": null,
"id": 2,
"server": null,
"active_reservation": null
},
{
"name": "T3",
"restaurant_id": 1,
"status": "assigned",
"server_id": 4,
"waiting_since": null,
"seats": null,
"id": 3,
"server": {
"id": 4,
"username": "server1"
},
"active_reservation": null
},
{
"name": "T4",
"restaurant_id": 1,
"status": "assigned",
"server_id": 6,
"waiting_since": null,
"seats": null,
"id": 4,
"server": {
"id": 6,
"username": "server2"
},
"active_reservation": null
}
]

The status of Table:
class TableStatus(str, Enum):
FREE     = "free"
RESERVED = "reserved"
WAITING  = "waiting"
ASSIGNED = "assigned"
DIRTY = "dirty"
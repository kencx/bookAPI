from books import views
from django.urls import include, path
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r"books", views.BookViewSet, basename="books")
router.register(r"users", views.UserViewSet, basename="users")

urlpatterns = [
    path("", include(router.urls)),
]

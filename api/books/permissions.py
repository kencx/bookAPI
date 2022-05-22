from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Only allow owner to edit book metadata
    """

    def has_object_permission(self, request, view, obj):
        # read permissions
        if request.method in permissions.SAFE_METHODS:
            return True

        # write permissions
        return obj.owner == request.user

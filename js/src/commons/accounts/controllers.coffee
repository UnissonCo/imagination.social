module = angular.module("commons.accounts.controllers", ['commons.accounts.services'])

module.controller("CommunityCtrl", ($scope, Profile, ObjectProfileLink) ->
    """
    Controller pour la manipulation des data d'une communauté liée à un objet partagé (project, fiche resource, etc.    )
    La sémantique des niveaux d'implication est à préciser en fonction de la resource.
    A titre d'exemple, pour les projets et fiche ressource MakerScience :
    - 0 -> Membre de l'équipe projet
    - 1 -> personne ressource
    - 2 -> fan/follower
    """

    $scope.profiles = Profile.getList().$object
    $scope.teamCandidate = null
    $scope.resourceCandidate = null
    $scope.currentUserCandidate = false
    $scope.community = []

    $scope.init = (objectTypeName) ->

        $scope.$on(objectTypeName+'Ready', (event, args) ->
            $scope.addMember = (profile, level, detail, isValidated)->
                # Check if selected profile is not already added with given level
                ObjectProfileLink.one().customPOST(
                    profile_id: profile.id,
                    level: level,
                    detail : detail,
                    isValidated:isValidated
                , $scope.objectTypeName+'/'+$scope.object.id).then((objectProfileLinkResult) ->
                    $scope.community.push(objectProfileLinkResult)
                )

            $scope.removeMember = (member) ->
                # attention confusion possible : member ici correspond à une instance de 
                # ObjectProfileLink. L'id du profil concerné e.g se trouve à member.profile.id
                ObjectProfileLink.one(member.id).remove().then(()->
                    memberIndex = $scope.community.indexOf(member)
                    $scope.community.splice(memberIndex, 1)
                )

            $scope.validateMember = ($event, member) ->
                validated = $event.target.checked
                console.log(" Validating ?? !", validated)
                ObjectProfileLink.one(member.id).patch({isValidated : validated}).then(
                    memberIndex = $scope.community.indexOf(member)
                    member = $scope.community[memberIndex]
                    member.isValidated = validated
                    )
            
            $scope.updateMemberDetail = (detail, member) ->
                ObjectProfileLink.one(member.id).patch({detail : detail}).then(
                    memberIndex = $scope.community.indexOf(member)
                    member = $scope.community[memberIndex]
                    member.detail = detail
                    )

            $scope.objectTypeName = objectTypeName
            $scope.object = args[objectTypeName]
            $scope.community = ObjectProfileLink.one().customGETLIST($scope.objectTypeName+'/'+$scope.object.id).$object
        )
)
